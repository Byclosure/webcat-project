class ProjectImport
  constructor: ->
    setTimeout ->
       Turbolinks.visit(location.href)
    , 5000

@ProjectImport = ProjectImport
