rest = require "request"

client_id = process.env.CLIENT_ID or "3MVG9y6x0357Hlef0sJ1clNGWyYjGIN0fGQjmzawi2ojX6xQ_4MbJ7l1Xbl54iZcWCdFd5N1FTepUjq3DX12L"
client_secret = process.env.CLIENT_SECRET or "7701266349787425657"

class module.exports
   constructor: (auth) ->
      @client_id = client_id
      @access_token = auth.access_token
      @refresh_token = auth.refresh_token
      @api_version = "v26.0"
      @instance_url = "https://na1.database.com" #auth.instance_url # FIGURE THIS OUT
      @login_url = "https://login.salesforce.com"

   refreshAccessToken: (callback) ->
      options = 
         url: "#{this.login_url}/services/oauth2/token?grant_type=refresh_token&client_id=#{escape(this.clientId)}&client_secret=#{escape(client_secret)}&refresh_token=#{escape(this.refreshToken)}"
         method: "POST"
      rest options, callback

   ajax: (path, callback, method, payload, retry) ->
      console.log "URL:", "#{@instance_url}/services/data#{path}"
      options = 
         url: "#{@instance_url}/services/data#{path}"
         method: method or "GET"
         json: payload
         headers: "Authorization": "OAuth #{@access_token}"
      rest options, (error, req, body) =>
         console.log "\n\nREQ: ", req.headers
         console.log "\n\nBODY: ", body
         if req.statusCode == 401 and not retry
            @refreshAccessToken (error, req, body) =>
               console.log "\n\nREFRESH REQ: ", req
               console.log "\n\nREFRESH BODY: ", body

               if req.statusCode >= 400
                  throw "Refresh Error: #{body}"

               @access_token = body.access_token
               @instance_url = body.instance_url
               @ajax(path, callback, method, payload, true)
         else
            callback error, req, body

   describeGlobal: (callback) ->
      @ajax("/#{@api_version}/", callback)

   metadata: (objtype, callback) ->
      @ajax("/#{@api_version}/sobjects/#{objtype}/", callback)

   describe: (objtype, callback) ->
      @ajax("/#{@api_version}/sobjects/#{objtype}/describe/", callback)

   create: (objtype, fields, callback) ->
      @ajax("/#{@api_version}/sobjects/#{objtype}/", callback, "POST", JSON.stringify(fields))

   retrieve: (objtype, id, fieldlist, callback) ->
      if not arguments[3]
         callback = fieldlist
         fieldlist = null

      fields = if fieldlist then "?fields=" + fieldlist else ""

      @ajax("/#{@api_version}/sobjects/#{objtype}/#{id}#{fields}", callback)

   upsert: (objtype, externalIdField, externalId, fields, callback) ->
      @ajax("/#{@api_version}/sobjects/#{objtype}/#{externalIdField}/#{externalId}?_HttpMethod=PATCH", callback, "POST", JSON.stringify(fields))

   update: (objtype, id, fields, callback) ->
      @ajax("/#{@api_version}/sobjects/#{objtype}/#{id}?_HttpMethod=PATCH", callback, "POST", JSON.stringify(fields));

   del: (objtype, id, callback) ->
      @ajax("/#{@api_version}/sobjects/#{objtype}/#{id}", callback, "DELETE")

   query: (soql, callback) ->
      @ajax("/#{@api_version}/query?q=#{escape(soql)}", callback)

   queryMore: (url, callback) ->
      serviceData = "services/data"
      index = url.indexOf(serviceData)
      if index > -1
         url = url.substr(index + serviceData.length)
      @ajax(url, callback)

   search: (sosl, callback) ->
      @ajax("/#{@api_version}/search?q=#{escape(sosl)}", callback)
