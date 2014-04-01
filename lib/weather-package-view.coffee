{View} = require 'atom'

module.exports =
class WeatherPackageView extends View
  @content: ->
    @div class: 'weather-package overlay from-top from-right', =>
        @div "City", class: "city", id: "city"
        @div "Temperature", class: "temp", id: "temp"
        @div "Pressure", class: "pressure", id: "pressure"

  initialize: (serializeState) ->
    atom.workspaceView.command "weather-package:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
      return

    atom.workspaceView.appendToBottom(this)
    city = atom.config.get("weather-package.city")
    unless (city?)
      city = "Kiev"
      atom.config.set("weather-package.city", city)

    fahrenheit = atom.config.get("weather-package.showInFahrenheit");
    unless ( fahrenheit? )
      fahrenheit = true
      atom.config.set("weather-package.showInFahrenheit", true)

    that = this
    view = this
    constructor = {
      units: "imperial"
      unitTemp: "F"
      unitPress: "hPa"
      correctPress: 1
    }
    if not fahrenheit
      constructor.units = "metric"
      constructor.unitTemp = "C"
      constructor.unitPress = "mmHg"
      constructor.correctPress = 1.33
    xml = new XMLHttpRequest()
    xml.addEventListener 'readystatechange', ->
      if xml.readyState == 4 and xml.status == 200
        oJSON = JSON.parse xml.responseText
        pressure = oJSON.main.pressure/constructor.correctPress
        view.find("#city").text "City: " + oJSON.name + " " + oJSON.weather[0].description
        view.find("#temp").text "Temperature: " + oJSON.main.temp.toFixed() + " " + constructor.unitTemp
        view.find("#pressure").text "Pressure: " + pressure.toFixed(2) + " " + constructor.unitPress
    sUrl = "http://api.openweathermap.org/data/2.5/weather?q=" + city + "&units="+ constructor.units
    xml.open "get", sUrl , true
    xml.send()

    remove = () ->
      view.detach()
    #setTimeout(remove, 7000)
