
function onClickMoveBookmarkButton() {
    webkit.messageHandlers.callbackHandler.postMessage("MoveBookmark");
}

function onClickRemoveBookmarkButton() {
    webkit.messageHandlers.callbackHandler.postMessage("RemoveBookmark");
}

function displayMoveButton() {
    var animation = getElement("lds-ellipsis", 0);
    animation.style.display = "none"
    var bookmarkImage = getElement("bookmark-image", 0);
    var bookmarkText = getElement("move-bookmark-text", 0);
    bookmarkImage.style.display = "inline-block";
    bookmarkText.style.display = "inline-block";
}

function hideMoveButton() {
    var bookmarkImage = getElement("bookmark-image", 0);
    var bookmarkText = getElement("move-bookmark-text", 0);
    bookmarkImage.style.display = "none";
    bookmarkText.style.display = "none";
    var animation = getElement("lds-ellipsis", 0);
    animation.style.display = "inline-block"
}

function displayRemoveButton() {
    var animation = getElement("lds-ellipsis", 1);
    animation.style.display = "none"
    var bookmarkImage = getElement("bookmark-image", 1);
    var bookmarkText = getElement("bookmark-text", 0);
    bookmarkImage.style.display = "inline-block";
    bookmarkText.style.display = "inline-block";
}

function hideRemoveButton() {
    var bookmarkImage = getElement("bookmark-image", 1);
    var bookmarkText = getElement("bookmark-text", 0);
    bookmarkImage.style.display = "none";
    bookmarkText.style.display = "none";
    var animation = getElement("lds-ellipsis", 1);
    animation.style.display = "inline-block"
}

function getElement(className, index) {
    return document.getElementsByClassName(className)[index];
}
