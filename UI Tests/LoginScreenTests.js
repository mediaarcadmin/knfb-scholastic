#import "tuneup/tuneup.js"
#import "Scholastic.js"

test("GoToScreen LoginScreen", function(target, app) {
    GoToScreen("LoginScreen");
});

test("LoginScreen Contents", function(target, app) {    
    assertWindow({ 
        "navigationBar": { 
            rightButton: null, 
        },
        
        "scrollViews": [{
            elements: [
            { name: "Sign In" }
            ]
        }]
    });
    
});