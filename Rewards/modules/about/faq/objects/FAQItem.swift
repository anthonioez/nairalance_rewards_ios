//
//  FAQItem.swift
//  Rewards
//
//  Created by Anthonio Ez on 09/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class FAQItem: NSObject
{
    var id = 0;
    var question: String = ""
    var answer: String = ""
    var order = 0;
    
    var answerAttr: NSMutableAttributedString! = nil
    var expanded = false;
    var parent = 0
    var height = CGFloat(0);

    
    public override init()
    {
        self.id         = 0;
        self.question   = "";
        self.answer     = "";
        self.order      = 0;
    }
    
    init(id: Int, question: String, answer: String, parent: Int)
    {
        self.id = id;
        self.question = question;
        self.answer = answer;
        self.parent = parent;
    }
    
    init(parent: Int, answer: String)
    {
        self.id = 0;
        self.question = ""
        self.answer = answer;
        self.parent = parent;
        self.answerAttr    = UI.fromHtml(self.answer, color: Rewards.colorDetail, font: Rewards.font.withSize(14));
    }
    
    public func copyJSON(json: [String: Any]?) -> Bool
    {
        if(json == nil) { return false }
        
        self.id         = (json!["id"] as? Int) ?? 0;
        
        self.question   = (json!["question"] as? String) ?? "";
        self.answer     = (json!["answer"] as? String) ?? "";
        self.order      = (json!["order"] as? Int) ?? 0;
        
        return true;
    }

}
