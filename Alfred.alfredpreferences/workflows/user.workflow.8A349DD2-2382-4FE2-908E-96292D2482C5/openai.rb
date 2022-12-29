require 'net/http'
require 'uri'
require 'json'

# models = [
#   "text-davinci-003",
#   "text-curie-001",
#   "text-babbage-001",
#   "text-ada-001",
#   "text-davinci-002",
#   "text-davinci-001",
#   "davinci-instruct-beta",
#   "davinci",
#   "curie-instruct-beta",
#   "curie",
#   "babbage",
#   "ada",
#   "code-davinci-002",
#   "code-cushman-001"
# ]

def parse(json)
  res = JSON.parse(json)
  if res["error"]
    print "❗️ ERROR: ##{res["error"]["message"]}"
    exit
  else
    choices = res["choices"]
    return choices[0]
  end
end

def send_query(apikey, query, timeout_sec)
  target_uri = "https://api.openai.com/v1/completions"
  uri = URI.parse(target_uri)

  headers = {
    "Content-Type" => "application/json",
    "Authorization"=> "Bearer #{apikey}"
  }
  req = Net::HTTP::Post.new(uri, headers)

  req.body = query.to_json
  
  req_options = {
    use_ssl: uri.scheme == "https",
    read_timeout: timeout_sec,
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(req)
  end
  return parse response.body
end

def make_query(text, mode, model, first_language, second_language, max_tokens, temperature, top_p, frequency_penalty, presence_penalty, echo)
  case mode
  when "text_input"
    query = {
      "model" => model,
      "prompt" => text,
      "max_tokens" => max_tokens,
      "temperature" => temperature,
      "top_p" => top_p,
      "frequency_penalty" =>  frequency_penalty,
      "presence_penalty" => presence_penalty,
      "echo" => echo,
    }
  when "general"
    query = {
      "model" => model,
      "prompt" => text,
      "max_tokens" => max_tokens,
      "temperature" => temperature,
      "top_p" => 1,
      "frequency_penalty" =>  frequency_penalty,
      "presence_penalty" => presence_penalty,
      "echo" => echo,
    }
  when "write_program_code"
    query = {
      "model" => model,
      "prompt" => "#{text}\n\nReturn the response program code and examples all in a strictly valid markdown format",
      "max_tokens" => max_tokens,
      "temperature" => 0.0,
      "top_p" => 0.0,
      "frequency_penalty" =>  0,
      "presence_penalty" => 0,
      "echo" => echo,
    }
  when "question_in_your_language"
    if first_language.to_s == ""
      sleep 1
      print "❗️ ERROR: variable your_first_language not specified"
      exit
    end
    query = {
      "model" => model,
      "prompt" => "Answer the question in #{first_language} below using #{first_language}:\n\n" + "Q: #{text}\n\nA: ",
      "max_tokens" => max_tokens,
      "temperature" => 0.0,
      "top_p" => 0.0,
      "frequency_penalty" =>  0,
      "presence_penalty" => 0,
      "echo" => echo,
    }
  when "question_in_your_language"
    if first_language.to_s == ""
      sleep 1
      print "❗️ ERROR: variable your_first_language not specified"
      exit
    end
    query = {
      "model" => model,
      "prompt" => "Answer the question in #{first_language} below using #{first_language}:\n\n" + "Q: #{text}\n\nA: ",
      "max_tokens" => max_tokens,
      "temperature" => 0.0,
      "top_p" => 0.0,
      "frequency_penalty" =>  0,
      "presence_penalty" => 0,
      "echo" => echo,
    }
  when "translate_l1_to_l2"
    if first_language.to_s == "" || second_language.to_s == ""
      sleep 1
      print "❗️ ERROR: variables your_first_language and your_second_language not specified"
      exit
    end
    query = {
      "model" => model,
      "prompt" => "Translate this #{first_language} text to #{second_language}:\n\n" + text,
      "max_tokens" => max_tokens,
      "temperature" => 0.3,
      "top_p" => 1.0,
      "frequency_penalty" =>  0,
      "presence_penalty" => 0,
      "echo" => echo,
    }
  when "translate_l2_to_l1"
    if first_language.to_s == "" || second_language.to_s == ""
      sleep 1
      print "❗️ ERROR: variables your_first_language and your_second_language not specified"
      exit
    end
    query = {
      "model" => model,
      "prompt" => "Translate this #{second_language} text to #{first_language}:\n\n" + text,
      "max_tokens" => max_tokens,
      "temperature" => 0.3,
      "top_p" => 1.0,
      "frequency_penalty" =>  0,
      "presence_penalty" => 0,
      "echo" => echo,
    }
  when "summarization"
    query = {
      "model" => model,
      "prompt" => "Summarize the folloing text:\n\n" + text,
      "max_tokens" => max_tokens,
      "temperature" => 0.7,
      "top_p" => 1.0,
      "frequency_penalty" =>  0,
      "presence_penalty" => 0,
      "echo" => echo,
    }
  when "analogy_maker"
    query = {
      "model" => model,
      "prompt" => "Create an analogy for this phrase:\n\n" + text + " in that:",
      "max_tokens" => max_tokens,
      "temperature" => 0,
      "top_p" => 1.0,
      "frequency_penalty" =>  0,
      "presence_penalty" => 0,
      "echo" => echo,
    }
  when "essay_outline"
    query = {
      "model" => model,
      "prompt" => "Create an outline for an essay about " + text + "?",
      "max_tokens" => max_tokens,
      "temperature" => 0,
      "top_p" => 1.0,
      "frequency_penalty" =>  0,
      "presence_penalty" => 0,
      "echo" => echo,
    }
  when "create_study_notes"
    query = {
      "model" => model,
      "prompt" => "What are 5 key points I should know when studying " + text + "?",
      "max_tokens" => max_tokens,
      "temperature" => 0.3,
      "top_p" => 1,
      "frequency_penalty" =>  0,
      "presence_penalty" => 0,
      "echo" => echo,
    }
  when "q_and_a"
    query = {
      "model" => model,
      "prompt" => "I am a highly intelligent question answering bot. If you ask me a question that is rooted in truth, I will give you the answer. If you ask me a question that is nonsense, trickery, or has no clear answer, I will respond with 'Unknown'.\n\nQ: " + text,
      "temperature" => 0,
      "max_tokens" => max_tokens,
      "top_p" => 1,
      "frequency_penalty" =>  0,
      "presence_penalty" => 0,
      "echo" => echo,
    }
  when "grammar_correction"
    query = {
      "model" => model,
      "prompt" => "Correct this to standard English:\n\n" + text,
      "max_tokens" => max_tokens,
      "temperature" => 0,
      "top_p" => 1,
      "frequency_penalty" =>  0,
      "presence_penalty" => 0,
      "echo" => echo,
    }
  when "summarize_for_a_2nd_grader"
    query = {
      "model" => model,
      "prompt" => "Summarize this for a second-grade student:\n\n" + text,
      "max_tokens" => max_tokens,
      "temperature" => 0.7,
      "top_p" => 1,
      "frequency_penalty" =>  0.0,
      "presence_penalty" => 0.0,
      "echo" => echo,
    }
  when "brainstorm"
    query = {
      "model" => model,
      "prompt" => "Brainstorm some ideas about " + text,
      "max_tokens" => max_tokens,
      "temperature" => 0.6,
      "top_p" => 1,
      "frequency_penalty" =>  0.0,
      "presence_penalty" => 0.0,
      "echo" => echo,
    }
  when "keywords"
    query = {
      "model" => model,
      "prompt" => "Extract keywords from this text:\n\n" + text,
      "max_tokens" => max_tokens,
      "temperature" => 0.3,
      "top_p" => 1,
      "frequency_penalty" =>  0.8,
      "presence_penalty" => 0.0,
      "echo" => echo,
    }
  end
  query
end

def execute_query(apikey:, mode:, model:, first_language:, second_language:,
                  max_tokens:, temperature:, top_p:, frequency_penalty:,
                  presence_penalty:, max_characters:, timeout_sec:, echo:)

  if apikey.to_s == ""
    sleep 1
    print "❗️ ERROR: API key is not set"
    exit
  end

  text = `pbpaste | textutil -convert txt -stdin -stdout`.strip

  if text == ""
    sleep 1
    print "❗️ ERROR: Input text is empty"
    exit
  end

  max_tokens        = max_tokens.to_i
  temperature       = temperature.to_f
  top_p             = top_p.to_f
  frequency_penalty = frequency_penalty.to_f
  presence_penalty  = presence_penalty.to_f
  max_characters    = max_characters.to_i
  timeout_sec       = timeout_sec.to_s == "" ? 1200 : timeout_sec.to_i 
  echo              = echo.to_s.strip == "true" ? true : false

  if text.length > max_characters.to_i
    sleep 1
    print "❗️ ERROR: Input text contains #{text.length} characters; max number of characters is set to #{max_characters}"
    exit
  elsif /\A\s*\z/ =~ text
    sleep 1
    print "❗️ ERROR: Input text is empty"
    exit
  end

  query = make_query(text, mode, model, first_language, second_language, max_tokens, temperature, top_p, frequency_penalty, presence_penalty, echo)
  json = send_query(apikey, query, timeout_sec)

  if json["finish_reason"] == "length"
    sleep 1
    print "❗️ ERROR: Max tokens (#{max_tokens}) is not enough for this request"
    exit
  elsif json["text"].to_s == ""
    sleep 1
    print "❗️ ERROR: Response is empty: Review your settings and prompt"
    exit
  end

  results= json["text"].to_s.strip
  puts results
end
