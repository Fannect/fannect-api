express = require "express"
rest = require "request"
Browser = require "zombie"
url = require "url"
qs = require "qs"
request = require "request"

app = module.exports = express()

client_id = process.env.CLIENT_ID or "3MVG9y6x0357Hlef0sJ1clNGWyYjGIN0fGQjmzawi2ojX6xQ_4MbJ7l1Xbl54iZcWCdFd5N1FTepUjq3DX12L"
client_secret =  process.env.CLIENT_SECRET or "7701266349787425657"

redirect_uri = "https://login.salesforce.com/services/oauth2/success"
login_base_url = "https://login.salesforce.com/services/oauth2/authorize?response_type=code&client_id=#{escape(client_id)}&redirect_uri=#{escape(redirect_uri)}&scope=api%20id%20web%20refresh_token"

app.post "/api/login", (req, res, next) ->
   email = req.body.email
   password = req.body.password

   if not email or not password
      return res.json
         status: "fail"
         error_message: "Email and Password are required."

   browser = null

   Browser.visit login_base_url, runScripts: false, loadCSS: false, (err, b) ->
      browser = b
      browser.evaluate browser.query("script").innerHTML
      browser.wait executeLogin
         
   executeLogin = () ->
      browser.evaluate "document.getElementsByName('username')[0].value = '#{email}';"
      browser.evaluate "document.getElementsByName('pw')[0].value = '#{password}';"
      browser.evaluate "document.getElementsByName('un')[0].value = '#{email}';"
      browser.evaluate "document.getElementsByName('width')[0].value = 10;"
      browser.evaluate "document.getElementsByName('height')[0].value = 10;"
      browser.evaluate "handleLogin = function(){ return true; };"
      browser.evaluate "document.getElementsByClassName('loginButton')[0].click();"
      browser.wait executeAccept

   executeAccept = () ->
      if browser.evaluate "document.getElementsByClassName('loginError').length > 0"
         message = browser.evaluate "document.getElementsByClassName('loginError')[0].innerHTML"
         return res.json 
            status: "fail"
            error_message: message

      if browser.evaluate "document.getElementById('oaapprove')"
         browser.evaluate "document.getElementById('oaapprove').click();"
         browser.wait executeRedirect
      else
         browser.evaluate browser.query("script").innerHTML
         browser.wait executeRedirect

   executeRedirect = () ->
      browser.evaluate browser.query("script").innerHTML
      browser.wait parseCode

   parseCode = () ->
      console.log qs.parse(url.parse(browser.location.href).query).code
      request.post 'https://login.database.com/services/oauth2/token',
         form:
            grant_type: "authorization_code"
            client_id: client_id
            client_secret: client_secret
            redirect_uri: redirect_uri
            code: qs.parse(url.parse(browser.location.href).query).code
      , (err, resp, body) ->
         auth = JSON.parse body
         req.session = req.session or {}
         req.session.auth = auth
         req.session.user_id = auth.id.match(/[^//]*$/)[0]
         res.json status: "success"
