// @ts-nocheck // using pure javascript without the whole toolchain here
const obsidian = require("obsidian");
//------------------------------------------------------------------------------

const SETTINGS = {
	intervalMins: 60,
	messages: [
		"🚰 Clara, trink was!",
		"🚿 Merke: Alle zwei Tage duschen, alle zwei Stunden trinken!",
		"😔 Wenn du nicht jetzt was trinkst, ist Chris ganz traurig.",
		"💸 Trink oder gib Chris 10€ – deine Entscheidung!",
		"🌵 Du bist keine Zimmerpflanze. Gieß dich.",
		"🧠 Dein Gehirn hätte gern etwas Flüssigkeit.",
		"🥤 Trink jetzt, bevor dein Mund zur Wüste wird.",
		"🚒 Durst entdeckt. Gegenmaßnahmen jetzt einleiten.",
		"🫗 Ein Glas Wasser kostet weniger als Kopfschmerzen.",
		"🤖 Erinnerung: Menschliche Systeme benötigen regelmäßig Wasser.",
		"🚿 Nein, Duschen ersetzt Trinken nicht.",
		"📢 Wasserpause! Das ist keine Übung.",
		"🧃 Dein zukünftiges Ich bedankt sich für den nächsten Schluck.",
		"🐟 Fische würden jetzt trinken. Sei wie ein Fisch.",
		"🥛 Dein Getränk fühlt sich ignoriert.",
		"🚰 Trink einen Schluck. Du prokrastinierst sowieso gerade.",
		"🦥 Selbst Faultiere trinken regelmäßig.",
		"💧 Herzlichen Glückwunsch. Du hast schon wieder vergessen zu trinken.",
		"🚨 Dein Körper sendet Warnmeldungen. Du ignorierst sie weiterhin souverän.",
		"⏳ Trink Wasser. Oder warte einfach, bis dein Organismus Beschwerde einlegt.",
		"📅 Du wolltest später trinken. Es ist jetzt später.",
		"📉 Dehydrierung ist eine interessante Strategie. Mal sehen, wie sie ausgeht.",
		"📱 Du hast Zeit zum Scrollen. Du hast Zeit für ein Glas Wasser.",
		"🧃 Trink etwas. Oder erklär deinem Körper später, warum nicht.",
		"💡 Hydration ist einfacher zu lösen als die meisten deiner Probleme.",
		"🫀 Deine Nieren beobachten dich mit Enttäuschung. Trink.",
		"🧩 Stell dir vor, du wärst so konsequent beim Trinken wie beim Prokrastinieren.",
		"👀 Wenn du das hier lesen kannst, kannst du auch Wasser holen.",
		"😐 Du ignorierst diese Trink-Erinnerung mit beeindruckender Konsequenz.",
	],
};

//------------------------------------------------------------------------------

class DrinkReminderPlugin extends obsidian.Plugin {
	intervalId = 0;

	onload() {
		console.info(this.manifest.name + " loaded.");

		setInterval(() => {
			const msgId = Math.floor(Math.random() * SETTINGS.messages.length);
			new Notice(SETTINGS.messages[msgId], 15_000);
		}, SETTINGS.intervalMins * 1000 * 60);
	}
}

module.exports = DrinkReminderPlugin;
