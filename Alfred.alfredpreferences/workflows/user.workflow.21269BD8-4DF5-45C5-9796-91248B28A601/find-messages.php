<?php

use Alfred\Workflows\Workflow;

require __DIR__ . '/vendor/autoload.php';

// determine how many minutes to look back
$lookBackMinutes = max(0, (int) @$argv[1]) ?: 15;

$workflow = new Workflow;

$dbPath = $_SERVER['HOME'] . '/Library/Messages/chat.db';

if (! is_readable($dbPath)) {
    $workflow->result()
             ->title('ERROR: Unable to Access Your Messages')
             ->subtitle('We were unable to access the file that contains your text messages')
             ->arg('')
             ->valid(true);
    echo $workflow->output();
    exit;
}

try {
    $db = new PDO('sqlite:' . $dbPath);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    $workflow->result()
             ->title('ERROR: Unable to Access Your Messages')
             ->subtitle('We were unable to access the file that contains your text messages')
             ->arg('')
             ->valid(true);
    $workflow->result()
             ->title('Error Message:')
             ->subtitle($e->getMessage())
             ->arg('')
             ->valid(true);
    echo $workflow->output();
    exit;
}

try {
    $query = $db->query("
        select
            message.rowid,
            ifnull(handle.uncanonicalized_id, chat.chat_identifier) AS sender,
            message.service,
            datetime(message.date / 1000000000 + 978307200, 'unixepoch', 'localtime') AS message_date,
            message.text
        from
            message
                left join chat_message_join
                        on chat_message_join.message_id = message.ROWID
                left join chat
                        on chat.ROWID = chat_message_join.chat_id
                left join handle
                        on message.handle_id = handle.ROWID
        where
            message.is_from_me = 0
            and message.text is not null
            and length(message.text) > 0
            and (
                message.text glob '*[0-9][0-9][0-9]*'
                or message.text glob '*[0-9][0-9][0-9][0-9]*'
                or message.text glob '*[0-9][0-9][0-9][0-9][0-9]*'
                or message.text glob '*[0-9][0-9][0-9][0-9][0-9][0-9]*'
                or message.text glob '*[0-9][0-9][0-9]-[0-9][0-9][0-9]*'
                or message.text glob '*[0-9][0-9][0-9][0-9][0-9][0-9][0-9]*'
                or message.text glob '*[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]*'
            )
            and datetime(message.date / 1000000000 + strftime('%s', '2001-01-01'), 'unixepoch', 'localtime')
                    >= datetime('now', '-$lookBackMinutes minutes', 'localtime')
        order by
            message.date desc
        limit 100
    ");
} catch (PDOException $e) {
    $workflow->result()
             ->title('ERROR: Unable to Query Your Messages')
             ->subtitle('We were unable to run the query that reads your text messages')
             ->arg('')
             ->valid(true);
    $workflow->result()
             ->title('Error Message:')
             ->subtitle($e->getMessage())
             ->arg('')
             ->valid(true);
    echo $workflow->output();
    exit;
}

$found = 0;
$max = 8;

while ($message = $query->fetch(PDO::FETCH_ASSOC)) {
    $code = null;
    $text = $message['text'];

    // remove URLs
    $text = preg_replace('/\b((https?|ftp|file):\/\/|www\.)[-A-Z0-9+&@#\/%?=~_|$!:,.;]*[A-Z0-9+&@#\/%=~_|$]/i', '', $text);

    // skip now-empty messages
    $text = trim($text);

    if (empty($text)) {
        continue;
    }

    if (preg_match('/(^|\s|\R|\t|\b|G-|:)(\d{5,8})($|\s|\R|\t|\b|\.|,)/', $text, $matches)) {
        // 5-8 consecutive digits
        // examples:
        //   "您的验证码是 199035，10分钟内有效，请勿泄露"
        //   "登录验证码：627823，您正在尝试【登录】，10分钟内有效"
        //   "【赛验】验证码 54538"
        //   "Enter this code to log in:59678."
        //   "G-315643 is your Google verification code"
        //   "Enter the code 765432, and then click the button to log in."
        //   "Your code is 45678!"
        //   "Your code is:98765!"
        $code = $matches[2];
    } elseif (preg_match('/^(\d{4,8})(\sis your.*code)/', $text, $matches)) {
        // 4-8 digits followed by "is your [...] code"
        // examples:
        //   "2773 is your Microsoft account verification code"
        $code = $matches[1];
    } elseif (preg_match('/(code:|is:)\s*(\d{4,8})($|\s|\R|\t|\b|\.|,)/i', $text, $matches)) {
        // "code:" OR "is:", optional whitespace, then 4-8 consecutive digits
        // examples:
        //   "Your Airbnb verification code is: 1234."
        //   "Your verification code is: 1234, use it to log in"
        //   "Here is your authorization code:9384"
        $code = $matches[2];
    } elseif (preg_match('/(code|is):?\s*(\d{3,8})($|\s|\R|\t|\b|\.|,)/i', $text, $matches)) {
        // "code" OR "is" followed by an optional ":" + optional whitespace, then 3-8 consecutive digits
        // examples:
        //   "Please enter code 548 on Zocdoc."
        $code = $matches[2];
    } elseif (preg_match('/(^|code:|is:|\b)\s*(\d{3})-(\d{3})($|\s|\R|\t|\b|\.|,)/', $text, $matches)) {
        // line beginning OR "code:" OR "is:" OR word boundary, optional whitespace, 3 consecutive digits, a hyphen, then 3 consecutive digits
        // but NOT a phone number (###-###-####)
        // examples:
        //   "123-456"
        //   "Your Stripe verification code is: 719-839."
        $first = $matches[2];
        $second = $matches[3];

        // make sure it isn't a phone number
        // doesn't match: <first digits>-<second digits>-<4 consecutive digits>
        if (! preg_match('/(^|code:|is:|\b)\s*' . $first . '-' . $second . '-(\d{4})($|\s|\R|\t|\b|\.|,)/', $text, $matches)) {
            $code = $first . $second;
        }
    }

    if ($code) {
        $found++;
        $date = formatDate($message['message_date']);
        $text = formatText($message['text']);
        $sender = formatSender($message['sender']);

        $workflow->result()
                 ->title($code)
                 ->subtitle("$date from $sender: $text")
                 ->arg($code)
                 ->valid(true);

        if ($found >= $max) {
            break;
        }
    }
}

if (! $found) {
    $workflow->result()
             ->title('No 2FA Codes Found')
             ->subtitle("No two-factor auth codes were found in your text messages from the past $lookBackMinutes minutes")
             ->arg('')
             ->valid(true);
}

echo $workflow->output();

/**
 * Format the date of the message
 *
 * @param string $date
 *
 * @return string
 */
function formatDate($date)
{
    $time = strtotime($date);

    if (date('m/d/Y', $time) === date('m/d/Y')) {
        return 'Today @ ' . date('g:ia', $time);
    }

    return date('M j @ g:ia', $time);
}

/**
 * Format the text of the message
 *
 * @param string $text
 *
 * @return string
 */
function formatText($text)
{
    return str_replace(
        ["\n", ':;'],
        ['; ', ':'],
        trim($text)
    );
}

/**
 * Format a sender number
 *
 * @param string $sender
 *
 * @return string
 */
function formatSender($sender)
{
    $sender = trim($sender, '+');

    if (strlen($sender) === 11 && substr($sender, 0, 1) === '1') {
        $sender = substr($sender, 1);
    }

    if (strlen($sender) === 10) {
        return substr($sender, 0, 3) . '-' . substr($sender, 3, 3) . '-' . substr($sender, 6, 4);
    }

    return $sender;
}
