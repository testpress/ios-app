/* Javascript to handle the selection of item in question list */

function onClickQuestionItem(clickedItem) {
    var message = { "clickedItemId": clickedItem.id }
    webkit.messageHandlers.callbackHandler.postMessage(message);
}
