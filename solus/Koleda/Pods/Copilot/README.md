### How to build the copilot-sdk-ios project
<<<<<<< .merge_file_eTcZuD
1. You should use Xcode 10.1
2. Checkout the project from `https://bitbucket.org/teamcopilot/copilot-sdk-ios.git`
3. In Xcode, open the preference menu -> Locations tab. Under the command line tools property make sure its tageted to Xcode 10.1
4. Install carthage using brew : `brew insall carthage`
5. Install the SDK Carthage depandancies - In project's main folder, execute `carthage bootstrap --platform iOS --no-use-binaries`
=======
1. You should use Xcode 10.1.x
2. Checkout the project from `https://bitbucket.org/teamcopilot/copilot-sdk-ios.git`
3. In Xcode, open the preference menu -> Locations tab. Under the command line tools property make sure its targeted to Xcode 10.0
4. Install the SDK Carthage dependencies - In project's main folder, execute `carthage bootstrap --platform iOS --no-use-binaries`
>>>>>>> .merge_file_jBpIRW

### How to run tests
1. In Xcode, choose the relevant module scheme and edit it.
2. Test on left menu. Tests files list will be listed, choose which test files to execute as part of the scheme.
3. Long press on play to execute the selected tests scheme.

### Rake script explanation
We use ruby make script (rake) to deploy the SDK binary to private CocoaPod. The rake script performs the following:
* Determines SDK's version from plist file or from user input (If version entered manually will update the plist file).
* Creates universal build each of the related application framework using xcodebuild
* Compress every application framework
* Upload each compressed framework to remote location (currently we use bitbucket downloads).
* Commit, push and tag this version in the SDK source control with the SDK's version.
* Update podspecs for the private pod and push to specs repository.

### What to do in order to release new build?
1.  Make sure you have write access to 3 repositories : 
	* `copilot-sdk-ios` - The actual SDK git repository.
	* `copilot-sdk-ios-specs`  - SDK's public git repository with the cocoapods pod specs files.
	* `copilot-sdk-ios-releases` - Public repository containing the actual library artifacts.

3. In Xcode, open the preference menu -> Location tab. Under the command line tools property make sure its targeted to Xcode 10.0.x. In order to validate you are running with 10.0.x xcodebuild, excute `xcodebuild -version` in the terminal.
4. Install xcodebuild-rb
		```bash
		$ gem 'xcodebuild-rb', '~> 0.3.0'
		```
5. Add the private pod copilot SDK specs to your CocoaPods - should be done only once per machine:
	```bash
	$ pod repo add copilot-sdk-ios-specs https://bitbucket.org/teamcopilot/copilot-sdk-ios-specs.git
	``` 
	In order to validate if you have the Copilot specs in your local CocoaPods go 	to your /Users/your_user_name/.cocoapods/repos folder (in order to see hidden files in finder press cmd+shift+. in your finder 	window)

> Consider making it hard coded and then skip script's local pod folder question.

3. Must have ruby gems : `cocoa-pods`, `rake`, `xcodebuild`.
> Consider making ruby gem file to install all required dependencies.
4. Navigate to projects base folder and execute `rake release`.
5. During the script invocation you'll need to answer few questions:
	* Select version number (plist or manually) - if you'll choose manually plist will be updated.
	* Put your bitbucket username and password.
	* Select the local pod folder (copilot-sdk-ios-specs).
