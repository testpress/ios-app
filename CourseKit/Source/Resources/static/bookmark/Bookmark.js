
function onClickBookmarkButton() {
    webkit.messageHandlers.callbackHandler.postMessage("ClickedBookmarkButton");
}

function updateBookmarkButtonState(bookmarked, basePath) {
    var bookmarkImage = getElement("bookmark-image");
    var bookmarkText = getElement("bookmark-text");
    if (bookmarked) {
        bookmarkImage.src = basePath + "/images/remove_bookmark.svg";
        bookmarkText.innerHTML = "Remove Bookmark";
    } else {
        bookmarkImage.src = basePath + "/images/bookmark.svg";
        bookmarkText.innerHTML = "Bookmark this";
    }
    currentBookmarkState = bookmarked;
    displayBookmarkButton()
}

function displayBookmarkButton() {
    var animation = getElement("lds-ellipsis");
    animation.style.display = "none"
    var bookmarkImage = getElement("bookmark-image");
    var bookmarkText = getElement("bookmark-text");
    bookmarkImage.style.display = "inline-block";
    bookmarkText.style.display = "inline-block";
}

function hideBookmarkButton() {
    var bookmarkImage = getElement("bookmark-image");
    var bookmarkText = getElement("bookmark-text");
    bookmarkImage.style.display = "none";
    bookmarkText.style.display = "none";
    var animation = getElement("lds-ellipsis");
    animation.style.display = "inline-block"
}

function getElement(className) {
    return document.getElementsByClassName(className)[0];
}


