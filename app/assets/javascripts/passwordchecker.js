$(document).ready(function(){
	// console.log('Registering keyup event...');
	$('#newPassword').on('keyup', checkPassword);
});

function checkPassword()
{
	// console.log('keyup event received');

	var lengthOK = false;
	var hasLowerLetter = false;
	var hasSpecialChar = false;

	if ($(this).val().length>7)				// Mindestlänge: 8 Zeichen
	{
		lengthOK = true;
	}

	if ($(this).val().match(/[a-z]/))			// Mindestens ein Kleinbuchstabe
	{
		hasLowerLetter = true;
	}

	if ($(this).val().match(/[^A-Za-z0-9]/))		// Mindestens ein Sonderzeichen

	{
		hasSpecialChar = true;
	}

	if (! $('#resultsElement').length)
	{
		addResultsElement();
	} else {
		// console.log("resultsDiv is existing");
	}

	if (lengthOK)
	{
		$('#resultLength').html('<span class="good">✔</span> Das Passwort ist lang genug.');
	} else {
		$('#resultLength').html('<span class="bad">✖</span> Das Passwort muss eine Länge von mindestens 8 Zeichen haben.');
	}

	if (hasLowerLetter)
	{
		$('#resultLetter').html('<span class="good">✔</span> Das Passwort enthält einen Kleinbuchstaben.')
	} else {
		$('#resultLetter').html('<span class="bad">✖</span> Das Passwort muss mindestens einen Kleinbuchstaben enthalten.');
	}

	if (hasSpecialChar)
	{
		$('#resultSpecialChar').html('<span class="good">✔</span> Das Passwort enthält ein Sonderzeichen.');
	} else {
		$('#resultSpecialChar').html('<span class="bad">✖</span> Das Passwort muss mindestens ein Sonderzeichen enthalten.');
	}

	if (lengthOK && hasLowerLetter && hasSpecialChar)
	{
		$('#resultAll').html('<span class="good">✔</span> <strong>Das Passwort entspricht den Richtlinien.</strong>');
	} else {
		$('#resultAll').html('<span class="bad">✖</span> <strong>Das Passwort entspricht nicht den Richtlinien.</strong>');
	}
}


function addResultsElement()
{
	var $resultsElememt = $('<td>')
		.attr('id', 'resultsElement')
                .append('<span id="resultLength"></span><br />')
                .append('<span id="resultLetter"></span><br />')
                .append('<span id="resultSpecialChar"></span><br />')
                .append('<strong>⇒<strong> <span id="resultAll"></span>');

	$('#newPassword').parent().parent().after('<tr id="resultsParent">');
        $('#resultsParent').append('<td>').append($resultsElememt);

	// console.log('Added resultsElement');
}

