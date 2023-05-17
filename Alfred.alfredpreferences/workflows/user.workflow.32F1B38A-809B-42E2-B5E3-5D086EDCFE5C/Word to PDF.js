#!/usr/bin/osascript -l JavaScript

/****************************************************************
 * Convert Word documents to PDF either using macOS save-as-PDF
 * functionality, or Microsoft's online service.
 ***************************************************************/

'use strict';

// Menu/button titles. Change for non-English systems
const printDialogName = 'Print',
	pdfMenuName = 'PDF',
	pdfButtonName = 'Save as PDF',
	saveButtonName = 'Save',
	goButtonName = 'Go',
	replaceButtonName = 'Replace';


const currentApp = Application.currentApplication();
currentApp.includeStandardAdditions = true;

function getEnv(key) {
	return currentApp.systemAttribute(key);
}

// return true if environment variable is set to a truthy value.
function getBool(key) {
	return getEnv(key).toLowerCase().match(/(yes|true|1|on)/);
}

// Wait for specified UI element to (cease to) exist
function waitFor(ref, options) {
	options = options || {};
	let name = options['name'] || 'UI element';
	let gone = options['gone'] || false;

	let i = 0;
	// wait for max. 10 secs
	while (i < 100) {
		if (gone) {
			if (!ref.exists()) {
				console.log(`${name} does not exist`);
				return;
			}
		} else if (ref.exists()) {
			console.log(`${name} exists`);
			return;
		}
		console.log(`waiting for ${name} ...`);
		delay(0.1);
		i++;
	}

	throw `timed out waiting for ${name}`;
}


// run script
function run(argv) {
	// workflow settings
	const useOnlineService = getBool('USE_ONLINE_SERVICE'),
		openWithApp = getEnv('OPEN_WITH');

	const	word = Application('com.microsoft.Word'),
		fm = $.NSFileManager.defaultManager,
		se = Application('System Events'),
		finder = Application('Finder'),
		proc = se.processes['Microsoft Word'];

	word.useStandardAdditions = true;
	word.activate();

	let app = null;
	if (openWithApp) {
		app = Application(openWithApp);
	}
	argv.forEach(path => {
		// directory and filename of PDF version
		const fullpath = $.NSString.alloc.initWithUTF8String(path),
			filename = fullpath.lastPathComponent.stringByDeletingPathExtension.stringByAppendingString(".pdf"),
			dirpath = fullpath.stringByDeletingLastPathComponent,
			outPath = dirpath.stringByAppendingPathComponent(filename),
			exists = fm.fileExistsAtPath(outPath);

		console.log(`exporting "${path}" to "${outPath.js}" ...`);
		word.open(path);
		let doc = word.activeDocument;

		if (useOnlineService) {
			doc.saveAs({fileName: outPath.js, fileFormat: 'format PDF'});
		} else {
			// references to used UI elements
			const printDialog = proc.windows[printDialogName],
				pdfMenu = printDialog.menuButtons[pdfMenuName],
				pdfButton = pdfMenu.menus[0].menuItems[pdfButtonName],
				saveSheet = printDialog.sheets[0],
				goButton = saveSheet.buttons[goButtonName],
				goBox = saveSheet.comboBoxes[0],
				filenameBox = saveSheet.textFields[0],
				saveButton = saveSheet.buttons[saveButtonName],
				replaceButton = saveSheet.buttons[replaceButtonName];

			// open Print dialog
			se.keystroke('p', {using: 'command down'});
			waitFor(printDialog, {name: 'Print dialog'});

			// click "Save as PDF" in "PDF" menu
			pdfMenu.click();
			waitFor(pdfButton, {name: 'Save as PDF button'});
			pdfButton.click();

			// Save sheet
			waitFor(saveSheet, {name: 'Save Sheet'});
			// navigate to output directory
			se.keystroke('g', {using: ['command down', 'shift down']});
			waitFor(goButton, {name: 'Go button'});
			goBox.value.set(dirpath.js);
			goButton.click();
			// waitFor(goButton, {name: 'Go button', gone: true});

			// set filename
			filenameBox.value.set(filename.js);
			saveButton.click();

			// wait for and click "Replace" button if file exists
			if (exists) {
				waitFor(replaceButton, {name: 'Replace button'});
				replaceButton.click();
			}

			// wait for Print dialog to go away
			waitFor(printDialog, {name: 'Print dialog', gone: true});
		}

		doc.close({saving: 'no'});

		if (!app) return;

		let p = Path(outPath.js);
		if (openWithApp === 'Finder') app.reveal(p);
		else app.open(p);
	})

	if (app) app.activate();

	return `${argv.length} file(s) converted to PDF`;
}
