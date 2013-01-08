express = require "express"
rest = require "request"
Browser = require "zombie"
url = require "url"
qs = require "qs"

app = module.exports = express()

client_id = process.env.CLIENT_ID or "3MVG9y6x0357Hlef0sJ1clNGWyYjGIN0fGQjmzawi2ojX6xQ_4MbJ7l1Xbl54iZcWCdFd5N1FTepUjq3DX12L"
redirect_uri = "https://login.salesforce.com/services/oauth2/success"
login_base_url = "https://login.salesforce.com/services/oauth2/authorize?response_type=token&client_id=#{escape(client_id)}&redirect_uri=#{escape(redirect_uri)}"

app.post "/login", (req, res, next) ->
   email = req.query.email
   password = req.query.password

   if not email or not password
      return res.json
         status: "fail"
         error_message: "Email and Password are required."

   Browser.visit login_base_url, runScripts: false, loadCSS: false, (err, browser) ->
      browser.evaluate browser.query("script").innerHTML
      browser.wait () ->
         # Submit login information
         browser.evaluate "document.getElementsByName('username')[0].value = '#{email}';"
         browser.evaluate "document.getElementsByName('pw')[0].value = '#{password}';"
         browser.evaluate "document.getElementsByName('un')[0].value = '#{email}';"
         browser.evaluate "document.getElementsByName('width')[0].value = 10;"
         browser.evaluate "document.getElementsByName('height')[0].value = 10;"
         browser.evaluate "handleLogin = function(){ return true; };"
         browser.evaluate "document.getElementsByClassName('loginButton')[0].click();"
         browser.wait () ->
            # Check for login failure
            if browser.evaluate "document.getElementsByClassName('loginError').length > 0"
               message = browser.evaluate "document.getElementsByClassName('loginError')[0].innerHTML"
               return res.json
                  status: "fail"
                  error_message: message
                    
            browser.evaluate browser.query("script").innerHTML
            browser.wait () ->
               # Approve for the user
               browser.evaluate "document.getElementById('oaapprove').click();"
               browser.wait () ->
                  browser.evaluate browser.query("script").innerHTML
                  browser.wait () ->
                     # Parse successful response
                     query = qs.parse(url.parse(browser.location.href).hash.replace("#", ""))
                     res.json
                        status: "success"
                        access_token: query.access_token
                        refresh_token: query.refresh_token