package.preload['json']=(function(...)local e=string
local d=math
local c=table
local i=error
local a=tonumber
local l=tostring
local s=type
local o=setmetatable
local u=pairs
local f=ipairs
local r=assert
local n=Chipmunk
module("json")local n={buffer={}}function n:New()local e={}o(e,self)self.__index=self
e.buffer={}return e
end
function n:Append(e)self.buffer[#self.buffer+1]=e
end
function n:ToString()return c.concat(self.buffer)end
local t={backslashes={['\b']="\\b",['\t']="\\t",['\n']="\\n",['\f']="\\f",['\r']="\\r",['"']='\\"',['\\']="\\\\",['/']="\\/"}}function t:New()local e={}e.writer=n:New()o(e,self)self.__index=self
return e
end
function t:Append(e)self.writer:Append(e)end
function t:ToString()return self.writer:ToString()end
function t:Write(n)local e=s(n)if e=="nil"then
self:WriteNil()elseif e=="boolean"then
self:WriteString(n)elseif e=="number"then
self:WriteString(n)elseif e=="string"then
self:ParseString(n)elseif e=="table"then
self:WriteTable(n)elseif e=="function"then
self:WriteFunction(n)elseif e=="thread"then
self:WriteError(n)elseif e=="userdata"then
self:WriteError(n)end
end
function t:WriteNil()self:Append("null")end
function t:WriteString(e)self:Append(l(e))end
function t:ParseString(n)self:Append('"')self:Append(e.gsub(n,'[%z%c\\"/]',function(n)local t=self.backslashes[n]if t then return t end
return e.format("\\u%.4X",e.byte(n))end))self:Append('"')end
function t:IsArray(i)local n=0
local t=function(e)if s(e)=="number"and e>0 then
if d.floor(e)==e then
return true
end
end
return false
end
for e,i in u(i)do
if not t(e)then
return false,'{','}'else
n=d.max(n,e)end
end
return true,'[',']',n
end
function t:WriteTable(e)local n,r,i,t=self:IsArray(e)self:Append(r)if n then
for n=1,t do
self:Write(e[n])if n<t then
self:Append(',')end
end
else
local n=true;for t,e in u(e)do
if not n then
self:Append(',')end
n=false;self:ParseString(t)self:Append(':')self:Write(e)end
end
self:Append(i)end
function t:WriteError(n)i(e.format("Encoding of %s unsupported",l(n)))end
function t:WriteFunction(e)if e==Null then
self:WriteNil()else
self:WriteError(e)end
end
local l={s="",i=0}function l:New(n)local e={}o(e,self)self.__index=self
e.s=n or e.s
return e
end
function l:Peek()local n=self.i+1
if n<=#self.s then
return e.sub(self.s,n,n)end
return nil
end
function l:Next()self.i=self.i+1
if self.i<=#self.s then
return e.sub(self.s,self.i,self.i)end
return nil
end
function l:All()return self.s
end
local n={escapes={['t']='\t',['n']='\n',['f']='\f',['r']='\r',['b']='\b',}}function n:New(n)local e={}e.reader=l:New(n)o(e,self)self.__index=self
return e;end
function n:Read()self:SkipWhiteSpace()local n=self:Peek()if n==nil then
i(e.format("Nil string: '%s'",self:All()))elseif n=='{'then
return self:ReadObject()elseif n=='['then
return self:ReadArray()elseif n=='"'then
return self:ReadString()elseif e.find(n,"[%+%-%d]")then
return self:ReadNumber()elseif n=='t'then
return self:ReadTrue()elseif n=='f'then
return self:ReadFalse()elseif n=='n'then
return self:ReadNull()elseif n=='/'then
self:ReadComment()return self:Read()else
i(e.format("Invalid input: '%s'",self:All()))end
end
function n:ReadTrue()self:TestReservedWord{'t','r','u','e'}return true
end
function n:ReadFalse()self:TestReservedWord{'f','a','l','s','e'}return false
end
function n:ReadNull()self:TestReservedWord{'n','u','l','l'}return nil
end
function n:TestReservedWord(n)for r,t in f(n)do
if self:Next()~=t then
i(e.format("Error reading '%s': %s",c.concat(n),self:All()))end
end
end
function n:ReadNumber()local n=self:Next()local t=self:Peek()while t~=nil and e.find(t,"[%+%-%d%.eE]")do
n=n..self:Next()t=self:Peek()end
n=a(n)if n==nil then
i(e.format("Invalid number: '%s'",n))else
return n
end
end
function n:ReadString()local n=""r(self:Next()=='"')while self:Peek()~='"'do
local e=self:Next()if e=='\\'then
e=self:Next()if self.escapes[e]then
e=self.escapes[e]end
end
n=n..e
end
r(self:Next()=='"')local t=function(n)return e.char(a(n,16))end
return e.gsub(n,"u%x%x(%x%x)",t)end
function n:ReadComment()r(self:Next()=='/')local n=self:Next()if n=='/'then
self:ReadSingleLineComment()elseif n=='*'then
self:ReadBlockComment()else
i(e.format("Invalid comment: %s",self:All()))end
end
function n:ReadBlockComment()local n=false
while not n do
local t=self:Next()if t=='*'and self:Peek()=='/'then
n=true
end
if not n and
t=='/'and
self:Peek()=="*"then
i(e.format("Invalid comment: %s, '/*' illegal.",self:All()))end
end
self:Next()end
function n:ReadSingleLineComment()local e=self:Next()while e~='\r'and e~='\n'do
e=self:Next()end
end
function n:ReadArray()local t={}r(self:Next()=='[')local n=false
if self:Peek()==']'then
n=true;end
while not n do
local r=self:Read()t[#t+1]=r
self:SkipWhiteSpace()if self:Peek()==']'then
n=true
end
if not n then
local n=self:Next()if n~=','then
i(e.format("Invalid array: '%s' due to: '%s'",self:All(),n))end
end
end
r(']'==self:Next())return t
end
function n:ReadObject()local l={}r(self:Next()=='{')local t=false
if self:Peek()=='}'then
t=true
end
while not t do
local r=self:Read()if s(r)~="string"then
i(e.format("Invalid non-string object key: %s",r))end
self:SkipWhiteSpace()local n=self:Next()if n~=':'then
i(e.format("Invalid object: '%s' due to: '%s'",self:All(),n))end
self:SkipWhiteSpace()local o=self:Read()l[r]=o
self:SkipWhiteSpace()if self:Peek()=='}'then
t=true
end
if not t then
n=self:Next()if n~=','then
i(e.format("Invalid array: '%s' near: '%s'",self:All(),n))end
end
end
r(self:Next()=="}")return l
end
function n:SkipWhiteSpace()local n=self:Peek()while n~=nil and e.find(n,"[%s/]")do
if n=='/'then
self:ReadComment()else
self:Next()end
n=self:Peek()end
end
function n:Peek()return self.reader:Peek()end
function n:Next()return self.reader:Next()end
function n:All()return self.reader:All()end
function encode(n)local e=t:New()e:Write(n)return e:ToString()end
function decode(e)local e=n:New(e)return e:Read()end
function Null()return Null
end
end)package.preload['revmob_about']=(function(...)REVMOB_SDK={NAME="corona",VERSION="3.1.1"}end)package.preload['revmob_client']=(function(...)local i=require('json')require('revmob_about')require('revmob_utils')local n='https://api.bcfads.com'local e='9774d5f368157442'local t='4c6dbc5d000387f3679a53d76f6944211a7f2224'local t=e
Connection={wifi=nil,wwan=nil,hasInternetConnection=function()return(not network.canDetectNetworkStatusChanges)or(Connection.wifi or Connection.wwan)end}function RevMobNetworkReachabilityListener(e)if e.isReachable then
log("Internet connection available.")else
log("Could not connect to RevMob site. No ads will be available.")end
Connection.wwan=e.isReachableViaCellular
Connection.wifi=e.isReachableViaWiFi
log("IsReachableViaCellular: "..tostring(e.isReachableViaCellular))log("IsReachableViaWiFi: "..tostring(e.isReachableViaWiFi))end
if network.canDetectNetworkStatusChanges then
network.setStatusListener("revmob.com",RevMobNetworkReachabilityListener)log("Listening network reachability.")end
Device={identities=nil,country=nil,manufacturer=nil,model=nil,os_version=nil,connection_speed=nil,new=function(n,e)e=e or{}setmetatable(e,n)n.__index=n
e.identities=e:buildDeviceIdentifierAsTable()e.country=system.getPreference("locale","country")e.locale=system.getPreference("locale","language")e.manufacturer=e:getManufacturer()e.model=e:getModel()e.os_version=system.getInfo("platformVersion")if Connection.wifi then
e.connection_speed="wifi"elseif Connection.wwan then
e.connection_speed="wwan"else
e.connection_speed="other"end
return e
end,isSimulator=function(e)return"simulator"==system.getInfo("environment")or system.getInfo("name")==""or system.getInfo("name")=="iPhone Simulator"or system.getInfo("name")=="iPad Simulator"end,isAndroid=function(e)return"Android"==system.getInfo("platformName")end,isIphoneOS=function(e)return"iPhone OS"==system.getInfo("platformName")end,isIPad=function(e)return"iPad"==system.getInfo("model")end,getDeviceId=function(e)return(e:isSimulator()and t)or system.getInfo("deviceID")end,buildDeviceIdentifierAsTable=function(e)local e=e:getDeviceId()e=string.gsub(e,"-","")e=string.lower(e)if(string.len(e)==40)then
return{udid=e}elseif(string.len(e)==14 or string.len(e)==15 or string.len(e)==17 or string.len(e)==18)then
return{mobile_id=e}elseif(string.len(e)==16)then
return{android_id=e}else
log("WARNING: device not identified, no registration or ad unit will work")return nil
end
end,getManufacturer=function(e)local e=system.getInfo("platformName")if(e=="iPhone OS")then
return"Apple"end
return e
end,getModel=function(e)local e=e:getManufacturer()if(e=="Apple")then
return system.getInfo("architectureInfo")end
return system.getInfo("model")end}Client={payload={},adunit=nil,applicationId=nil,device=nil,new=function(e,n,t)local n={adunit=n,applicationId=t or RevMobSessionManager.appID,device=Device:new()}setmetatable(n,e)e.__index=e
return n
end,url=function(e)return n.."/api/v4/mobile_apps/"..e.applicationId.."/"..e.adunit.."/fetch.json"end,urlInstall=function(e)return n.."/api/v4/mobile_apps/"..e.applicationId.."/install.json"end,urlSession=function(e)return n.."/api/v4/mobile_apps/"..e.applicationId.."/sessions.json"end,payloadAsJsonString=function(e)return i.encode({device=e.device,sdk={name=REVMOB_SDK["NAME"],version=REVMOB_SDK["VERSION"]}})end,post=function(l,e,t)if(e==nil)then
return
end
local r=require('socket.http')local n=require("ltn12")local i={}local r,e,n=r.request{method="POST",url=l,source=n.source.string(e),headers={["Content-Length"]=tostring(#e),["Content-Type"]="application/json"},sink=n.sink.table(i),}local e={statusCode=e,response=i[1],headers=n}if t then
t(e)end
return e
end,fetch=function(n,e)if RevMobSessionManager.isSessionStarted()then
local t=coroutine.create(Client.post)coroutine.resume(t,n:url(),n:payloadAsJsonString(),e)else
local n={statusCode=0,response={error="Session not started"},headers={}}if e then
e(n)end
end
end,install=function(e,t)local n=coroutine.create(Client.post)coroutine.resume(n,e:urlInstall(),e:payloadAsJsonString(),t)end,startSession=function(e)local n=coroutine.create(Client.post)coroutine.resume(n,e:urlSession(),e:payloadAsJsonString(),listener)end}end)package.preload['revmob_utils']=(function(...)function log(e)print("[RevMob] "..tostring(e))io.output():flush()end
getLink=function(n,e)for t,e in ipairs(e)do
if e.rel==n then
return e.href
end
end
return nil
end
Screen={left=display.screenOriginX,top=display.screenOriginY,right=display.contentWidth-display.screenOriginX,bottom=display.contentHeight-display.screenOriginY,scaleX=display.contentScaleX,scaleY=display.contentScaleY,width=function(e)return e.right-e.left
end,height=function(e)return e.bottom-e.top
end,}getMarketURL=function(i,e)local t=require('socket.http')local n=require("ltn12")local r={}if e==nil then
e=""end
local n,e,i=t.request{method="POST",url=i,source=n.source.string(e),headers={["Content-Length"]=tostring(#e),["Content-Type"]="application/json"},sink=n.sink.table(r),}if(e==302 or e==303)then
local t="details%?id=[a-zA-Z0-9%.]+"local n="android%?p=[a-zA-Z0-9%.]+"local e=i['location']if(string.sub(e,1,string.len("market://"))=="market://")then
return e
elseif(string.match(e,t,1))then
local e=string.match(e,t,1)return"market://"..e
elseif(string.sub(e,1,string.len("amzn://"))=="amzn://")then
return e
elseif(string.match(e,n,1))then
local e=string.match(e,n,1)return"amzn://apps/"..e
else
return getMarketURL(e)end
end
return nil
end
end)package.preload['fullscreen']=(function(...)local n=require('json')require('revmob_client')require('revmob_utils')Fullscreen={ASSETS_PATH='revmob-assets/fullscreen/',DELAYED_LOAD_IMAGE=10,TMP_IMAGE_NAME="fullscreen.jpg",TMP_CLOSE_BUTTON_IMAGE_NAME='close_button.jpg',CLOSE_BUTTON_X=Screen.right-30,CLOSE_BUTTON_Y=Screen.top+40,CLOSE_BUTTON_WIDTH=Device:isIPad()and 30 or 35,DELAY=200,adClicked=false,clickUrl=nil,screenGroup=nil,adListener=nil,notifyAdListener=function(e)if Fullscreen.adListener then
Fullscreen.adListener(e)end
end,networkListener=function(e)local n,e=pcall(n.decode,e.response)if(not n or e==nil)then
log("Ad not received.")native.setActivityIndicator(false)Fullscreen.notifyAdListener({type="adNotReceived"})return
end
local e=e['fullscreen']['links']Fullscreen.clickUrl=getLink('clicks',e)Fullscreen.imageUrl=getLink('image',e)Fullscreen.closeButtonImageUrl=getLink('close_button',e)timer.performWithDelay(Fullscreen.DELAYED_LOAD_IMAGE,function()display.loadRemoteImage(Fullscreen.imageUrl,"GET",Fullscreen.loadImage,Fullscreen.TMP_IMAGE_NAME,system.TemporaryDirectory)end)end,loadImage=function(e)if e.isError then
log("Ad not received.")native.setActivityIndicator(false)Fullscreen.notifyAdListener({type="adNotReceived"})return
end
Fullscreen.localizedImage=e.target
Fullscreen.localizedImage.x=display.contentWidth/2
Fullscreen.localizedImage.y=display.contentHeight/2
Fullscreen.localizedImage.width=Screen:width()Fullscreen.localizedImage.height=Screen:height()Fullscreen.localizedImage.tap=function(e,e)Fullscreen.adClick()return true
end
Fullscreen.localizedImage.touch=function(e,e)return true
end
Fullscreen.localizedImage:addEventListener("tap",Fullscreen.localizedImage)Fullscreen.localizedImage:addEventListener("touch",Fullscreen.localizedImage)Fullscreen.loadCloseButtonImage()Fullscreen.create()log("Ad received")native.setActivityIndicator(false)Fullscreen.notifyAdListener({type="adReceived"})end,loadCloseButtonImage=function()local e=Fullscreen.ASSETS_PATH..'close_button.png'Fullscreen.closeButton=display.newImageRect(e,Fullscreen.CLOSE_BUTTON_WIDTH,Fullscreen.CLOSE_BUTTON_WIDTH)Fullscreen.closeButton.x=Fullscreen.CLOSE_BUTTON_X
Fullscreen.closeButton.y=Fullscreen.CLOSE_BUTTON_Y
Fullscreen.closeButton.width=Fullscreen.CLOSE_BUTTON_WIDTH
Fullscreen.closeButton.height=Fullscreen.CLOSE_BUTTON_WIDTH
Fullscreen.closeButton.tap=function(e,e)Fullscreen.back()Fullscreen.notifyAdListener({type="adClosed"})return true
end
Fullscreen.closeButton.touch=function(e,e)return true
end
Fullscreen.closeButton:addEventListener("tap",Fullscreen.closeButton)Fullscreen.closeButton:addEventListener("touch",Fullscreen.closeButton)end,create=function()Fullscreen.screenGroup=display.newGroup()Runtime:addEventListener("enterFrame",Fullscreen.update)Runtime:addEventListener("system",Fullscreen.onApplicationResume)Fullscreen.screenGroup:insert(Fullscreen.localizedImage)Fullscreen.screenGroup:insert(Fullscreen.closeButton)end,release=function(e)Runtime:removeEventListener("enterFrame",Fullscreen.update)Runtime:removeEventListener("system",Fullscreen.onApplicationResume)pcall(Fullscreen.localizedImage.removeEventListener,Fullscreen.localizedImage,"tap",Fullscreen.localizedImage)pcall(Fullscreen.localizedImage.removeEventListener,Fullscreen.localizedImage,"touch",Fullscreen.localizedImage)pcall(Fullscreen.closeButton.removeEventListener,Fullscreen.closeButton,"tap",Fullscreen.closeButton)pcall(Fullscreen.closeButton.removeEventListener,Fullscreen.closeButton,"touch",Fullscreen.closeButton)if Fullscreen.screenGroup then
Fullscreen.screenGroup:removeSelf()Fullscreen.screenGroup=nil
end
Fullscreen.adClicked=false
log("Fullscreen Released.")return true
end,back=function()timer.performWithDelay(Fullscreen.DELAY,Fullscreen.release)return true
end,adClick=function()if not Fullscreen.adClicked then
Fullscreen.adClicked=true
Fullscreen.notifyAdListener({type="adClicked"})local e=getMarketURL(Fullscreen.clickUrl)if e then
system.openURL(e)else
system.openURL(Fullscreen.clickUrl)end
Fullscreen.back()end
return true
end,update=function(e)if(Fullscreen.screenGroup)then
Fullscreen.screenGroup:toFront()end
end,show=function(e)Fullscreen.adListener=e
local e=Client:new("fullscreens")e:fetch(Fullscreen.networkListener)end,onApplicationResume=function(e)if e.type=="applicationResume"then
log("Application resumed.")Fullscreen.release()end
end,}end)package.preload['fullscreen_web']=(function(...)local t=require('json')require('revmob_client')require('revmob_utils')FullscreenWeb={autoshow=true,listener=nil,clickUrl=nil,htmlUrl=nil,new=function(e)local e=e or{}setmetatable(e,FullscreenWeb)return e
end,load=function(e)e.networkListener=function(n)local t,n=pcall(t.decode,n.response)if(not t or n==nil)then
log("Ad not received.")if e.listener~=nil then e.listener({type="adNotReceived"})end
native.setActivityIndicator(false)return
end
local n=n['fullscreen']['links']e.clickUrl=getLink('clicks',n)e.htmlUrl=getLink('html',n)if e.listener~=nil then e.listener({type="adReceived"})end
if e.autoshow then
e:show()end
end
local n=Client:new("fullscreens")n:fetch(e.networkListener)end,isLoaded=function(e)return e.htmlUrl~=nil and e.clickUrl~=nil
end,show=function(e)native.setActivityIndicator(false)if not e:isLoaded()then
log("The Fullscreen Ad is not loaded yet to be shown")return
end
e.clickListener=function(n)if string.sub(n.url,-string.len("#close"))=="#close"then
if e.changeOrientationListener then
Runtime:removeEventListener("orientation",e.changeOrientationListener)end
return false
end
if string.sub(n.url,-string.len("#click"))=="#click"then
if e.changeOrientationListener then
Runtime:removeEventListener("orientation",e.changeOrientationListener)end
local n=getMarketURL(e.clickUrl)system.openURL(n or e.clickUrl)return false
end
if n.errorCode then
log("Error: "..tostring(n.errorMessage))end
return true
end
local n={hasBackground=false,autoCancel=true,urlRequest=e.clickListener}e.changeOrientationListener=function(t)native.cancelWebPopup()timer.performWithDelay(200,function()native.showWebPopup(e.htmlUrl,n)end)end
timer.performWithDelay(1,function()native.showWebPopup(e.htmlUrl,n)end)Runtime:addEventListener("orientation",e.changeOrientationListener)end,close=function(e)if e.changeOrientationListener then
Runtime:removeEventListener("orientation",e.changeOrientationListener)end
native.cancelWebPopup()end,}FullscreenWeb.__index=FullscreenWeb
end)package.preload['fullscreen_chooser']=(function(...)local n=require('json')require('revmob_client')require('revmob_utils')require('fullscreen')require('fullscreen_web')FullscreenChooser={show=function(i)networkListener=function(e)local n,e=pcall(n.decode,e.response)if(not n or e==nil)then
log("Ad not received.")if self.listener~=nil then self.listener({type="adNotReceived"})end
native.setActivityIndicator(false)return
end
local e=e['fullscreen']['links']local t=getLink('clicks',e)local n=getLink('html',e)local l=getLink('image',e)local r=getLink('close_button',e)if n then
local e=FullscreenWeb.new({listener=i})e.htmlUrl=n
e.clickUrl=t
e:show()else
Fullscreen.clickUrl=t
Fullscreen.imageUrl=l
Fullscreen.closeButtonImageUrl=r
Fullscreen.show(i)timer.performWithDelay(Fullscreen.DELAYED_LOAD_IMAGE,function()display.loadRemoteImage(Fullscreen.imageUrl,"GET",Fullscreen.loadImage,Fullscreen.TMP_IMAGE_NAME,system.TemporaryDirectory)end)end
end
local e=Client:new("fullscreens")e:fetch(networkListener)end,}end)package.preload['banner']=(function(...)local t=require('json')require('revmob_client')require('revmob_utils')Banner={DELAYED_LOAD_IMAGE=10,TMP_IMAGE_NAME="bannerImage.jpg",WIDTH=(Screen:width()>640)and 640 or Screen:width(),HEIGHT=Device:isIPad()and 100 or 50*(Screen.bottom-Screen.top)/display.contentHeight,clickUrl=nil,imageUrl=nil,image=nil,x=nil,y=nil,width=nil,height=nil,adListener=nil,new=function(n,e)local e=e or{}setmetatable(e,n)n.__index=n
e.notifyAdListener=function(n)if e.adListener then
e.adListener(n)end
end
e.adClick=function(n)e.notifyAdListener({type="adClicked"})local n=getMarketURL(e.clickUrl)if n then
system.openURL(n)else
system.openURL(e.clickUrl)end
return true
end
e.adTouch=function(n)return true
end
e.update=function(n)if(e.image)then
if(e.image.toFront~=nil)then
e.image:toFront()else
e:release()end
end
end
local i=function(n)if e.image~=nil then
e:release()end
e.image=n.target
e:show()end
local t=function(n)local t,n=pcall(t.decode,n.response)if(not t or n==nil)then
log("Ad not received.")e.notifyAdListener({type="adNotReceived"})return
end
local n=n['banners'][1]['links']e.clickUrl=getLink('clicks',n)e.imageUrl=getLink('image',n)timer.performWithDelay(e.DELAYED_LOAD_IMAGE,function()display.loadRemoteImage(e.imageUrl,"GET",i,e.TMP_IMAGE_NAME,system.TemporaryDirectory)log("Ad received")e.notifyAdListener({type="adReceived"})end)end
local n=Client:new("banners")n:fetch(t)return e
end,notifyAdListener=function(e)if self.adListener then
self.adListener(e)end
end,show=function(e)if e.image~=nil then
e.image.alpha=1
end
e:setDimension()e:setPosition()e.image.tap=e.adClick
e.image.touch=e.adTouch
e.image:addEventListener("tap",e.image)e.image:addEventListener("touch",e.image)Runtime:addEventListener("enterFrame",e.update)end,hide=function(e)if e.image~=nil then
e.image.alpha=0
end
end,release=function(e)log("Releasing event listeners.")Runtime:removeEventListener("enterFrame",e.update)if e.image then
log("Removing image")pcall(e.image.removeEventListener,e.image,"tap",e.image)pcall(e.image.removeEventListener,e.image,"touch",e.image)e.image:removeSelf()end
e.image=nil
end,setPosition=function(e,n,t)e.x=n or e.x
e.y=t or e.y
if e.image then
e.image.x=e.x or(Screen.left+e.WIDTH/2)e.image.y=e.y or(Screen.bottom-e.HEIGHT/2)end
end,setDimension=function(e,t,n)e.width=t or e.width
e.height=n or e.height
if e.image then
e.image.width=e.width or e.WIDTH
e.image.height=e.height or e.HEIGHT
end
end,}end)package.preload['adlink']=(function(...)local e=require('json')require('revmob_client')require('revmob_utils')require('session_manager')AdLink={open=function()if RevMobSessionManager.isSessionStarted()then
local e=Client:new("links")system.openURL(getMarketURL(e:url(),e:payloadAsJsonString()))else
log("ERROR: The method RevMob.startSession(ids) has not been called")end
end,}end)package.preload['popup']=(function(...)local n=require('json')require('revmob_client')Popup={DELAYED_LOAD_IMAGE=10,YES_BUTTON_POSITION=2,message=nil,click_url=nil,adListener=nil,notifyAdListener=function(e)if Popup.adListener then
Popup.adListener(e)end
end,show=function(e)Popup.adListener=e
client=Client:new("pop_ups")client:fetch(Popup.networkListener)end,networkListener=function(e)local n,e=pcall(n.decode,e.response)if Popup.isParseOk(n,e)then
Popup.message=e["pop_up"]["message"]Popup.click_url=e["pop_up"]["links"][1]["href"]timer.performWithDelay(Popup.DELAYED_LOAD_IMAGE,function()local e=native.showAlert(Popup.message,"",{"No, thanks.","Yes, Sure!"},Popup.click)end)Popup.notifyAdListener({type="adReceived"})else
Popup.notifyAdListener({type="adNotReceived"})end
end,isParseOk=function(n,e)if(not n)then
return false
elseif(e==nil)then
return false
elseif(e["pop_up"]==nil)then
return false
elseif(e["pop_up"]["message"]==nil)then
return false
elseif(e["pop_up"]["links"]==nil)then
return false
elseif(e["pop_up"]["links"][1]==nil)then
return false
elseif(e["pop_up"]["links"][1]["href"]==nil)then
return false
end
return true
end,click=function(e)if"clicked"==e.action then
if Popup.YES_BUTTON_POSITION==e.index then
Popup.notifyAdListener({type="adClicked"})local e=getMarketURL(Popup.click_url)if e then
system.openURL(e)else
system.openURL(Popup.click_url)end
else
Popup.notifyAdListener({type="adClosed"})end
end
end}end)package.preload['advertiser']=(function(...)local i=require('json')require('revmob_client')require('revmob_utils')require('loadsave')Advertiser={registerInstall=function(n,e)revMobListener=function(t)local i,r=pcall(i.decode,t.response)if(i and t.statusCode==200)then
RevMobPrefs.addItem(n,true)RevMobPrefs.saveToFile()log("Install received.")if e~=nil then
e.notifyAdListener({type="installReceived"})end
else
log("Install not received.")if e~=nil then
e.notifyAdListener({type="installNotReceived"})end
end
end
RevMobPrefs.loadFromFile()local e=RevMobPrefs.getItem(n)if e==true then
log("Install already registered in this device")else
local e=Client:new("",n)e:install(revMobListener)end
end}end)package.preload['loadsave']=(function(...)local n=require('json')RevMobPrefs={FILENAME="revmob_sdk.json",preferences={},getItem=function(e)return RevMobPrefs.preferences[e]or nil
end,addItem=function(n,e)RevMobPrefs.preferences[n]=e
end,saveToFile=function()local e=system.pathForFile(RevMobPrefs.FILENAME,system.DocumentsDirectory)local e=io.open(e,"w")local n=n.encode(RevMobPrefs.preferences)e:write(n)io.close(e)end,loadFromFile=function()local e=system.pathForFile(RevMobPrefs.FILENAME,system.DocumentsDirectory)local e=io.open(e,"r")if e then
local t=e:read("*a")RevMobPrefs.preferences=n.decode(t)if RevMobPrefs.preferences==nil then
RevMobPrefs.preferences={}end
io.close(e)else
RevMobPrefs.saveToFile()RevMobPrefs.loadFromFile()end
end}end)package.preload['session_manager']=(function(...)require("revmob_utils")RevMobSessionManager={listenersRegistered=false,appID=nil,sessionStarted=false,startSession=function(e)if e then
if not RevMobSessionManager.sessionStarted then
RevMobSessionManager.appID=e
RevMobSessionManager.sessionStarted=true
local e=Client:new("")e:startSession()log("Session started for App ID: "..RevMobSessionManager.appID)else
log("Session has already been started for App ID: "..e)end
end
end,sessionManagement=function(e)if e.type=="applicationSuspend"then
RevMobSessionManager.sessionStarted=false
elseif e.type=="applicationResume"then
RevMobSessionManager.startSession(RevMobSessionManager.appID)end
end,isSessionStarted=function()return RevMobSessionManager.sessionStarted
end,}if RevMobSessionManager.listenersRegistered==false then
RevMobSessionManager.listenersRegistered=true
Runtime:removeEventListener("system",RevMobSessionManager.sessionManagement)Runtime:addEventListener("system",RevMobSessionManager.sessionManagement)end end)require('revmob_about')require('revmob_utils')require('revmob_client')require('fullscreen')require('fullscreen_web')require('fullscreen_chooser')require('banner')require('adlink')require('popup')require('advertiser')require('session_manager')local t='4f56aa6e3dc441000e005a20'local n=5e3
local e=function()log("ERROR: The method RevMob.startSession(ids) has not been called")end
RevMob={getRevMobApplicationID=function(n,e)local e=nil
if Device:isSimulator()then
e=t
log("Using App ID for simulator: "..e)else
e=n[system.getInfo("platformName")]log("App ID: "..tostring(e))end
return e
end,startSession=function(e)RevMobSessionManager.startSession(RevMob.getRevMobApplicationID(e))Advertiser.registerInstall(RevMob.getRevMobApplicationID(e))end,showFullscreen=function(t)if not RevMobSessionManager.isSessionStarted()then return e()end
native.setActivityIndicator(true)showFullscreenInTheNextFrame=function()Runtime:removeEventListener("enterFrame",showFullscreenInTheNextFrame)FullscreenChooser.show(t)end,timer.performWithDelay(n,function()native.setActivityIndicator(false)end)Runtime:addEventListener("enterFrame",showFullscreenInTheNextFrame)end,showFullscreenWeb=function(t)if not RevMobSessionManager.isSessionStarted()then return e()end
native.setActivityIndicator(true)local e=FullscreenWeb.new(t)showFullscreenWebInTheNextFrame=function()Runtime:removeEventListener("enterFrame",showFullscreenWebInTheNextFrame)e:load()end,timer.performWithDelay(n,function()native.setActivityIndicator(false)end)Runtime:addEventListener("enterFrame",showFullscreenWebInTheNextFrame)end,showFullscreenImage=function(e)native.setActivityIndicator(true)showFullscreenImageInTheNextFrame=function()Runtime:removeEventListener("enterFrame",showFullscreenImageInTheNextFrame)Fullscreen.show(e)end,timer.performWithDelay(n,function()native.setActivityIndicator(false)end)Runtime:addEventListener("enterFrame",showFullscreenImageInTheNextFrame)end,openAdLink=function()if not RevMobSessionManager.isSessionStarted()then return e()end
AdLink.open()end,createBanner=function(n)if not RevMobSessionManager.isSessionStarted()then return e()end
if n==nil then n={}end
return Banner:new(n)end,showPopup=function(n)if not RevMobSessionManager.isSessionStarted()then return e()end
Popup.show(n)end,printEnvironmentInformation=function(e)log("==============================================")log("RevMob Corona SDK: "..REVMOB_SDK["VERSION"])log("App ID in session: "..tostring(RevMobSessionManager.appID))if e then
log("User App ID for Android: "..tostring(e["Android"]))log("User App ID for iOS: "..tostring(e["iPhone OS"]))end
log("Device name: "..system.getInfo("name"))log("Model name: "..system.getInfo("model"))log("Device ID: "..system.getInfo("deviceID"))log("Environment: "..system.getInfo("environment"))log("Platform name: "..system.getInfo("platformName"))log("Platform version: "..system.getInfo("platformVersion"))log("Corona version: "..system.getInfo("version"))log("Corona build: "..system.getInfo("build"))log("Architecture: "..system.getInfo("architectureInfo"))log("Locale-Country: "..system.getPreference("locale","country"))log("Locale-Language: "..system.getPreference("locale","language"))end}