//
//  AttemptItemRepository.swift
//  ios-app
//
//  Created by Karthik on 19/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation

public class AttemptItemRepository: AttemptRepository {
    public func submitAnswer(id: Int) {
        let attemptItems = DBManager<AttemptItem>().getItemsFromDB(filteredBy: "id=\(id)", byKeyPath: "order")
        let attemptItem = attemptItems[0]
        DBManager<AttemptItem>().write {
            attemptItem.isAttempted = true
        }
        
        TPApiClient.saveAnswer(
            selectedAnswer: Array(attemptItem.savedAnswers),
            review: false,
            shortAnswer: attemptItem.currentShortText,
            gapFilledResponses: Array<GapFillResponse>(),
            endpointProvider: TPEndpointProvider(.saveAnswer, url: attemptItem.getSaveUrl()), attemptItem: attemptItem,
            completion: {
                newAttemptItem, error in
                if (newAttemptItem != nil) {
                    newAttemptItem?.attemptId = attemptItem.attemptId
                    newAttemptItem?.examQuestionId = attemptItem.examQuestionId
                    newAttemptItem?.index = attemptItem.index
                    newAttemptItem?.question = attemptItem.question
                    newAttemptItem?.order = attemptItem.order
                    newAttemptItem?.questionId = attemptItem.questionId
                    newAttemptItem?.isAttempted = true
                    DBManager<AttemptItem>().addData(object: newAttemptItem!)
                    DBManager<AttemptItem>().deleteFromDb(object: attemptItem)
                }
            }
        )
    }
    
    public func selectAnswer(id: Int, selectedOptions: [Int] = [], shortText: String = "") ->  AttemptItem  {
        let attemptItems = DBManager<AttemptItem>().getItemsFromDB(filteredBy: "id=\(id)", byKeyPath: "order")
        let attemptItem = attemptItems[0]
        DBManager<AttemptItem>().write {
            attemptItem.selectedAnswers.removeAll()
            attemptItem.selectedAnswers.append(objectsIn: selectedOptions)
            attemptItem.savedAnswers.removeAll()
            attemptItem.savedAnswers.append(objectsIn: selectedOptions)
            attemptItem.shortText = shortText
        }
        DBManager<AttemptItem>().addData(object: attemptItem)
        return attemptItem
    }
    
    public func getAttemptItem(id: Int) -> AttemptItem {
        return DBManager<AttemptItem>().getItemsFromDB(filteredBy: "id=\(id)", byKeyPath: "order").first!
    }
    
    public func getIndexOfFirstUnAttemptedItem(attemptId: Int) -> Int {
        let attemptItems = DBManager<AttemptItem>().getItemsFromDB(filteredBy: "attemptId=\(attemptId)", byKeyPath: "order")
        return attemptItems.firstIndex(where: {$0.isAttempted == false}) ?? 0
    }
}
