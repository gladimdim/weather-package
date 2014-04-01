WeatherPackageView = require './weather-package-view'

module.exports =
  weatherPackageView: null

  activate: (state) ->
    @weatherPackageView = new WeatherPackageView(state.weatherPackageViewState)

  deactivate: ->
    @weatherPackageView.destroy()

  serialize: ->
    weatherPackageViewState: @weatherPackageView.serialize()
