#import "tuneup/tuneup.js"
#import "Scholastic.js"

test("GoToScreen StartScreen", function(target, app) {
    GoToScreen("StartScreen");
});

test("StartScreen Contents", function(target, app) {
    assertWindow({ 
        "navigationBar": { 
            leftButton: null, 
            leftButton: null, 
        },
        
        "tableViews": [{
            cells: [
            { name: "Younger kids' bookshelf (3-6)" },
            { name: "Older kids' bookshelf (7+)" },
            { name: "Sign In" }
            ]
        }]
    });
    
});