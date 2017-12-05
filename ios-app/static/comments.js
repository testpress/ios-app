/* Javascript to handle the events in comments list */

function displayPreviousCommentsLoading() {
    var loader = document.getElementById("preview_comments_loading_layout");
    loader.style.display = "block";
}

function hidePreviousCommentsLoading() {
    var loader = document.getElementById("preview_comments_loading_layout");
    loader.style.display = "none";
}

function displayNewCommentsLoading() {
    var loader = document.getElementById("new_comments_loading_layout");
    loader.style.display = "block";
}

function hideNewCommentsLoading() {
    var loader = document.getElementById("new_comments_loading_layout");
    loader.style.display = "none";
}

function appendCommentItemsAtBottom(text) {
    var div = document.getElementById('comments_layout');
    div.innerHTML += text;
}

function appendCommentItemsAtTop(text) {
    var div = document.getElementById('comments_layout');
    text += div.innerHTML;
    div.innerHTML = text
}

function displayLoadMoreCommentsButton(text) {
    var button_layout = document.getElementsByClassName("load_more_comments_layout")[0];
    var button = document.getElementsByClassName("load_more_comments")[0];
    button.innerHTML = text;
    button_layout.style.display = "block";
}

function displayLoadNewCommentsButton(text) {
    var button_layout = document.getElementsByClassName("load_new_comments_layout")[0];
    var button = document.getElementsByClassName("load_new_comments")[0];
    button.innerHTML = text;
    button_layout.style.display = "block";
}

function loadMoreComments() {
    var button_layout = document.getElementsByClassName("load_more_comments_layout")[0];
    button_layout.style.display = "none";
    displayPreviousCommentsLoading();
    webkit.messageHandlers.callbackHandler.postMessage("LoadMoreComments");
}

function loadNewComments() {
    var button_layout = document.getElementsByClassName("load_new_comments_layout")[0];
    button_layout.style.display = "none";
    displayNewCommentsLoading();
    webkit.messageHandlers.callbackHandler.postMessage("LoadNewComments");
}

function sendComment() {
    var commentBox = document.getElementsByClassName("comment_box")[0];
    commentBox.blur();
    var message = {"comment": commentBox.innerHTML}
    webkit.messageHandlers.callbackHandler.postMessage(message);
}

function clearCommentBox() {
    var commentBox = document.getElementsByClassName("comment_box")[0];
    commentBox.innerHTML = ""
}

function displayEmptyCommentsDescription() {
    var label = document.getElementById("empty_comments_description");
    label.style.display = "block";
}

function hideEmptyCommentsDescription() {
    var label = document.getElementById("empty_comments_description");
    label.style.display = "none";
}
