$(document).ready(function(){
  // console.log('Registering keyup event...');
  $('#newPassword').on('keyup', checkPassword);
});

function checkPassword()
{
  // console.log('keyup event received');

  var MINLENGTH = 10;
  var lengthOK = false;
  var hasLowerLetter = false;
  var hasSpecialChar = false;

  if ($(this).val().length>=MINLENGTH)				// Mindestlänge: MINLENGTH Zeichen
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

  if ($(this).val().length>0 && ! $('#resultsElement').length)
  {
    addResultsElement();
  } else if ($(this).val().length === 0 && $('#resultsElement').length) {
    $('#resultsElement').remove();
    $('input[name=commit]').prop('disabled', false);
  }

  if ($(this).val().length>0) {
    if (lengthOK)
    {
      $('#resultLength').html('<span class="good">✔</span> Das Passwort ist lang genug.');
    } else {
      $('#resultLength').html('<span class="bad">✖</span> Das Passwort muss eine Länge von mindestens ' + MINLENGTH + ' Zeichen haben.');
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
      $('input[name=commit]').prop('disabled', false);
    } else {
      $('#resultAll').html('<span class="bad">✖</span> <strong>Das Passwort entspricht nicht den Richtlinien.</strong>');
      $('input[name=commit]').prop('disabled', true);
    }
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

