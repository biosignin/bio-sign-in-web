// ------------------------------------------
// localization tools
//
// v1.0
//  - first version
// ------------------------------------------

// this function tries to get a translation based on the element's current text and sets the text of the element
function LocalizeElement(element) {
    Logging.Info("--> (" + element + ")");
    
    try {
        // remove whitespaces
        if ($(element).text() != "") {
            var lbl = $(element).text().replace(/\s/g, "");

            Logging.Debug("current text=" + lbl);

            var newText = HtmlDecode(eval("langTags.ControlLabels." + lbl));

            if (newText != "") {

                Logging.Debug("newText=" + newText);
                $(element).text(newText);
            }
            else {
                Logging.Error("element '" + element + "' with text '" + lbl + "' was not found in language file!");
                $(element).text("[" + lbl + "]");
            }
        }
        else {
            Logging.Error("element '" + element + "' cannot be localized because it does not contain a text!");
        }
        
    }
    catch (err) {
        Logging.Error("Exception=" + err);
    }
}


// this function tries to get a translation based on the element's current text.
function LocalizeText(label) {
    Logging.Info("--> (" + label + ")");
    
    try {
        // remove whitespaces
        var lbl = label.replace(/\s/g, "");

        var newText = HtmlDecode(eval("langTags.ControlLabels." + lbl));
        
        if (newText != "") {
            Logging.Debug("<-- " + newText);
            return newText;
        }
        else {
            Logging.Error("label '" + lbl + "' not found in language file!");
            Logging.Debug("<-- " + "[" + lbl + "]");
            return "[" + lbl + "]";
        }
    }
    catch (err) {
        Logging.Error("exeption=" + err);
        Logging.Debug("<-- " + "[" + lbl + "]");
        return "[" + err + "]";
    }
}

// Url Decoder
function HtmlDecode(txt) {
    var randomID = Math.floor((Math.random() * 100000) + 1);
    $('body').append('<div id="random' + randomID + '"></div>');
    $('#random' + randomID).html(txt);
    var entity_decoded = $('#random' + randomID).html();
    $('#random' + randomID).remove();
    return entity_decoded;
}

// extends "String" with a formatter like in .NET
// example: "this is {0} really {1} function".format("a", "cool") => "this is a really cool function"
String.prototype.format = function () {
    var formatted = this;
    for (var i = 0; i < arguments.length; i++) {
        var regexp = new RegExp('\\{' + i + '\\}', 'gi');
        formatted = formatted.replace(regexp, arguments[i]);
    }
    return formatted;
};
