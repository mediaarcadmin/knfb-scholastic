/**
 * Go to a specified part of the Scholastic UI from any starting point
 * It does this by always going back to the start view and building back from there
 *
 */

function GoToStartScreen() {
    target = UIATarget.localTarget();
    application = target.frontMostApp();
    window = application.mainWindow();
        
     // Use a unique accessibility to determine if you are on a particular screen
    StartScreen = window.elements().firstWithName("Starting Tableview");
    LoginScreen = window.elements().firstWithName("Login View");
    
    if (StartScreen.isValid()) {
        // Do nothing
        UIALogger.logMessage("Started from StartScreen.");
    } else if (LoginScreen.isValid()) {
        // Get back to start view
        UIALogger.logMessage("Started from LoginScreen");
        LoginBackButton = window.toolbars()[0].elements().firstWithName("button close");
        LoginBackButton.tap();
        target.delay(2);
    } else {
        fail("Cannot determine what Screen the app started on");
    }
}

function GoToScreen(title) {

    target = UIATarget.localTarget();
    application = target.frontMostApp();
    mainWindow = application.mainWindow();
    
    try {
        
        GoToStartScreen();
        
        if (title == "StartScreen") {
            // Do nothing we are already there
        } else if (title == "LoginScreen") {
            table = mainWindow.tableViews()[0];
            
            signIn = table.elements().firstWithName("Sign In");
            assertNotNull(signIn, "No Sign In button found");
            signIn.tap();

        } else {
            fail("Don't know how to GoToScreen(" + title + ")");
        }
        
    }
    catch (e) {
        UIALogger.logError(e);
        if (options.logTree) target.logElementTree();
        UIALogger.logFail(title);
    }
}

function LoginAs(username, password) {
    
    target = UIATarget.localTarget();
    application = target.frontMostApp();
    mainWindow = application.mainWindow();
    
    try {
        
        GoToScreen("LoginScreen");
        
        scrollview = mainWindow.scrollViews()[0];
        
        userNameField = scrollview.elements().firstWithName("Login User Name");
        assertNotNull(userNameField, "No username field found");
        userNameField.setValue(username);
        
        passwordField = scrollview.elements().firstWithName("Login Password");
        assertNotNull(passwordField, "No password field found");
        passwordField.setValue(password);
        
        target.delay(0.5);
        passwordField.tap();
        target.delay(0.5);
        
        signIn = scrollview.elements().firstWithName("Login View Sign In Button");

        assertNotNull(signIn, "No Sign In button found");
        signIn.tap();
        
    }
    catch (e) {
        UIALogger.logError(e);
        if (options.logTree) target.logElementTree();
        UIALogger.logFail(title);
    }
}