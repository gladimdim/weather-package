{View} = require 'atom'

module.exports =
    class WeatherPackageView extends View
        @content: ->
            @div class: 'weather-package inline-block', =>
                @span "City", class: "city", id: "city"
                @span "Temperature", class: "temp", id: "temp"
                @span "Pressure", class: "pressure", id: "pressure"

        initialize: (serializeState) ->
            atom.workspaceView.command "weather-package:toggle", => @toggle()

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

            atom.workspaceView.statusBar?.prependRight(this);
            #atom.workspaceView.appendToBottom(this)
            city = atom.config.get("weather-package.city")
            unless (city?)
                city = "Kiev"
                atom.config.set("weather-package.city", city)

            fahrenheit = atom.config.get("weather-package.showInFahrenheit");
            unless ( fahrenheit? )
                fahrenheit = true
                atom.config.set("weather-package.showInFahrenheit", true)

            that = this

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
            if not this.interval
                view.interval = setInterval (=> @getData(view, constr, city)), 1800000
            @getData(view, constr, city)

        getData: (view, constr, city)->
            xml = new XMLHttpRequest()
            xml.addEventListener 'readystatechange', =>
              if xml.readyState == 4 and xml.status == 200
                oJSON = JSON.parse xml.responseText
                pressure = oJSON.main.pressure/constr.correctPress
                view.find("#city").text " " + oJSON.name + " " + oJSON.weather[0].description
                view.find("#temp").text " " + oJSON.main.temp.toFixed() + " " + constr.unitTemp
                view.find("#pressure").text " " + pressure.toFixed(2) + " " + constr.unitPress
            sUrl = "http://api.openweathermap.org/data/2.5/weather?q=" + city + "&units="+ constr.units
            xml.open "get", sUrl , true
            xml.send()
