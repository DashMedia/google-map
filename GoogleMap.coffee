class @GoogleMap
  constructor: (@apiKey, @mapCallBack, @hue)->
    @loadScript();
  

  loadScript: -> #call to generate maps
    window.mapCallBack = ()->
      window.gMap.getGeo()
    console.log "testing"
    script = document.createElement("script")
    script.type = "text/javascript"
    script.src = "http://maps.googleapis.com/maps/api/js?key="+@apiKey+"&sensor=false&callback="+@mapCallBack
    document.body.appendChild script


  
  smallMap: ->
    mapObj = @
    linkTag = "<a target=\"_blank\" href=\"http://maps.google.com.au/maps?q="
    address = encodeURIComponent(jQuery("#google_map").attr("data-address"))
    linkTag += address + "\">"
    imgTag = "<img src=\"http://maps.googleapis.com/maps/api/staticmap?zoom=17&format=png&sensor=false&size=640x400&maptype=roadmap&center="
    marker = "&markers=color:red%7Clabel:D%7C"
    geo = "" + encodeURIComponent mapObj.address
    geo = geo.replace("(", "")
    geo = geo.replace(" ", "")
    geo = geo.replace(")", "")
    marker += geo
    imgTag += geo + marker + "\"/>"
    linkTag += imgTag + "</a>"
    jQuery("#smallMap").html linkTag

  getGeo: ->
    mapObj = @
    geocoder = new google.maps.Geocoder()
    mapObj.address = jQuery("#google_map").attr("data-address")
    geocoder.geocode
      address: mapObj.address
    , (results, status) ->
      if status is google.maps.GeocoderStatus.OK
        geo = results[0].geometry.location
        mapObj.geoLocation = geo
        mapObj.attachMapEvents()
      else
        # console.log "Geocode was not successful for the following reason: " + status
        false

  setMaxHeight: ->
    $(window).on 'resize', ()->
      mapObj = @
      maxHeight = window.innerHeight * 0.5;
      # console.log $("#largeMap")
      $("#largeMap").css "height", "#{maxHeight}px"

    $(window).trigger 'resize'

  largeMap: ->
    mapObj = @
    # create hue styler if hue has been set
    styles = (if mapObj.hue? then [stylers: [
      {
        hue: mapObj.hue
      }
      {
        visibility: "on"
      }
    ]] else [])

    mapOptions =
      zoom: 16
      center: mapObj.geoLocation
      # mapTypeId: google.maps.MapTypeId.ROADMAP
      scrollwheel: false
      styles: styles
    map = new google.maps.Map(document.getElementById("largeMap"), mapOptions)
    marker = new google.maps.Marker(
      map: map
      position: mapObj.geoLocation
    )
    
    # map.setOptions styles: styles


  attachMapEvents: ->
    mapObj = @
    enquire.register "screen and (min-width:600px)",
      setup: ->
        mapObj.largeMap()
        mapObj.setMaxHeight()
      deferSetup: true