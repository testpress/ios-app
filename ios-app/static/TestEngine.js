/* Javascript to handle the selection of options in test engine */

// Handle radio button

var selectedRadioOption;

function initRadioGroup(selectedRadioOptionId) {
    if (selectedRadioOptionId != null) {
        setRadioButtonState(document.getElementById(selectedRadioOptionId), true);
    }
}

function onRadioOptionClick(clickedOption) {
    if (selectedRadioOption == clickedOption) {
        var message = {"type": "radio_response", "clickedOptionId": clickedOption.id, "checked": false, "radioOption": true }
        webkit.messageHandlers.callbackHandler.postMessage(message);
        setRadioButtonState(clickedOption, false);
        selectedRadioOption = null;
    } else {
        if (selectedRadioOption) {
            setRadioButtonState(selectedRadioOption, false);
        }
        var message = {"type": "radio_response", "clickedOptionId": clickedOption.id, "checked": true, "radioOption": true }
        webkit.messageHandlers.callbackHandler.postMessage(message);
        setRadioButtonState(clickedOption, true);
    }
}

function setRadioButtonState(option, check) {
    radioButton = getWidget(option);
    if (check) {
        if (radioButton.className.match(/(?:^|\s)radio-button-unchecked(?!\S)/)) {
            radioButton.className =
                radioButton.className.replace( /(?:^|\s)radio-button-unchecked(?!\S)/g , '' );
        }
        radioButton.className += " radio-button-checked";
        setSelectedOptionBackground(option);
        selectedRadioOption = option;
    } else {
        if (radioButton.className.match(/(?:^|\s)radio-button-checked(?!\S)/)) {
            radioButton.className =
                radioButton.className.replace( /(?:^|\s)radio-button-checked(?!\S)/g , '' );
        }
        radioButton.className += " radio-button-unchecked";
        removeBackground(option);
    }
}

// Handle check box

function initCheckBoxGroup(selectedCheckBoxOptionIds) {
    if (selectedCheckBoxOptionIds != null) {
        for (i = 0; i < selectedCheckBoxOptionIds.length; i++) {
            var optionItem = document.getElementById(selectedCheckBoxOptionIds[i]);
            setCheckboxState(optionItem, true);
        }
    }
}

function onCheckBoxOptionClick(option) {
    if (isCheckedOption(option)) {
        var message = {"type": "checkbox_response", "clickedOptionId": option.id, "checked": false, "radioOption": false }
        webkit.messageHandlers.callbackHandler.postMessage(message);
        setCheckboxState(option, false);
    } else {
        var message = {"type": "checkbox_response", "clickedOptionId": option.id, "checked": true, "radioOption": false }
        webkit.messageHandlers.callbackHandler.postMessage(message);
        setCheckboxState(option, true);
    }
}

function setCheckboxState(option, check) {
    checkBox = getWidget(option);
    if (check) {
        if (checkBox.className.match(/(?:^|\s)checkbox-unchecked(?!\S)/)) {
            checkBox.className = checkBox.className.replace( /(?:^|\s)checkbox-unchecked(?!\S)/g , '' );
        }
        checkBox.className += " checkbox-checked";
        setSelectedOptionBackground(option);
    } else {
        if (checkBox.className.match(/(?:^|\s)checkbox-checked(?!\S)/)) {
            checkBox.className = checkBox.className.replace( /(?:^|\s)checkbox-checked(?!\S)/g , '' );
        }
        checkBox.className += " checkbox-unchecked";
        removeBackground(option);
    }
}

function onValueChange(element) {
    var message = {"type": "short_text_response", "shortText": element.value };
    webkit.messageHandlers.callbackHandler.postMessage(message);
}

function onEssayValueChange(element) {
    var message = {"type": "essay_response", "essay": element.value };
    webkit.messageHandlers.callbackHandler.postMessage(message);
}

function onFillInTheBlankValueChange(element) {
    var message = {"order": element.getAttribute("data-order"), "answer": element.value, "type": "gap_filled_response"}
    webkit.messageHandlers.callbackHandler.postMessage(message);
}

function onUploadFileButtonClick() {
    var message = {"type": "file_upload"}
    webkit.messageHandlers.callbackHandler.postMessage(message);
}

function clearFile() {
    var message = {"type": "clear_uploaded_file"}
    webkit.messageHandlers.callbackHandler.postMessage(message);
}

// Common functions

function getWidget(layout) {
    return document.getElementsByName(layout.id)[0];
}

function isCheckedOption(option) {
    return option.className.match(/(?:^|\s)selected-item(?!\S)/);
}

function setSelectedOptionBackground(layout) {
    layout.className += " selected-item";
}

function removeBackground(layout) {
    layout.className = layout.className.replace( /(?:^|\s)selected-item(?!\S)/g , '' );
}

function addWatermark(imageUrl) {
    document.body.pseudoStyle("before", "background-image", `url(${imageUrl})`);
    document.body.classList.add("watermark");
}


