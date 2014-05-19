{View} = require 'atom'
{ConfigObserver} = require 'atom'

module.exports =
  class WeatherPackageView extends View

    @content: ->
      @div class: 'weather-package inline-block', =>
        @span "Getting weather", class: "city", id: "city"
        @span "", class: "temp", id: "temp"
        @span "", class: "pressure", id: "pressure"

    initialize: (serializeState) ->
      atom.workspaceView.command "weather-package:toggle", => @toggle()
      atom.config.setDefaults("weather-package", city: "Kiev")
      atom.config.setDefaults("weather-package", refreshIntervalInMinutes: 30)

      # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
      @detach()

    interval: null
    toggle: ->
      view = this

      if @hasParent()
          clearInterval this.interval
          this.interval = null
          @detach()
          return

      atom.workspaceView.statusBar?.prependRight(this)

      #in settings value is saved in minutes.
      #need to do corrections to translate to ms.
      iTimeout = atom.config.get("weather-package.refreshIntervalInMinutes")
      if iTimeout
        iTimeout = iTimeout * 60 * 1000
      else
        iTimeout = 1800000
        atom.config.set("weather-package.refreshIntervalInMinutes", iTimeout / 60000)

      if not this.interval
          view.interval = setInterval (=> @getData(view)), iTimeout
      @getData(view)

    getData: (view) ->
      city = atom.config.get("weather-package.city")

      fahrenheit = atom.config.get("weather-package.showInFahrenheit")
      unless fahrenheit?
        fahrenheit = true
        atom.config.set("weather-package.showInFahrenheit", false)
      constr = {
        units: "imperial"
        unitTemp: "F"
        unitPress: "hPa"
        correctPress: 1
      }
      if not fahrenheit
        constr.units = "metric"
        constr.unitTemp = "C"
        constr.unitPress = "mmHg"
        constr.correctPress = 1.33

      showTemp = atom.config.get("weather-package.showTemperature")
      unless showTemp?
        showTemp = true
        atom.config.set("weather-package.showTemperature", true)

      showPressure = atom.config.get("weather-package.showPressure")
      unless showPressure?
        showPressure = true
        atom.config.set("weather-package.showPressure", true)

      xml = new XMLHttpRequest()
      xml.addEventListener 'readystatechange', =>
        if xml.readyState == 4 and xml.status == 200
          oJSON = JSON.parse xml.responseText
          pressure = oJSON.main.pressure/constr.correctPress
          view.find("#city").text " " + oJSON.name + " " + oJSON.weather[0].description
          if showTemp
            view.find("#temp").text " " + oJSON.main.temp.toFixed() + " " + constr.unitTemp
          else
            view.find("#temp").text ""
          if showPressure
            view.find("#pressure").text " " + pressure.toFixed(2) + " " + constr.unitPress
          else
            view.find("#pressure").text ""
      sUrl = "http://api.openweathermap.org/data/2.5/weather?q=" + city + "&units="+ constr.units
      xml.open "get", sUrl , true
      xml.send()
