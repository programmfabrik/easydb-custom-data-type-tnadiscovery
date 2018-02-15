class CustomDataTypeTNADiscovery extends CustomDataTypeWithCommons

  #######################################################################
  # return name of plugin
  getCustomDataTypeName: ->
    "custom:base.custom-data-type-tnadiscovery.tnadiscovery"


  #######################################################################
  # return name (l10n) of plugin
  getCustomDataTypeNameLocalized: ->
    $$("custom.data.type.tnadiscovery.name")


  #######################################################################
  # handle editorinput
  renderEditorInput: (data, top_level_data, opts) ->
    #console.error @, data, top_level_data, opts, @name(), @fullName()
    if not data[@name()]
        cdata = {
            conceptName : ''
            conceptURI : ''
            discoveryID : ''
            discoveryURL : ''
            referenceNumber : ''
            locationHeld : ''
            title : ''
            description : ''
        }
        data[@name()] = cdata
    else
        cdata = data[@name()]

    # render popover
    @__renderEditorInputPopover(data, cdata)



  #######################################################################
  # show tooltip with loader and then additional info
  __getAdditionalTooltipInfo: (tnadiscoveryID, tooltip, extendedInfo_xhr) ->
    that = @

    # abort eventually running request
    if extendedInfo_xhr.xhr != undefined
      extendedInfo_xhr.xhr.abort()

    # start new request to tnadiscovery-API
    # http://C3218935
    extendedInfo_xhr.xhr = new (CUI.XHR)(url: location.protocol + '//jsontojsonp.gbv.de/?url=http%3A%2F%2Fdiscovery.nationalarchives.gov.uk%2FAPI%2Frecords%2Fv1%2Fdetails%2F' + tnadiscoveryID)
    extendedInfo_xhr.xhr.start()
    .done((data, status, statusText) ->
      htmlContent = ''
      for own key, value of data
        if value != null && value != 'null' && value != 0 && value != '0' && value != ''
          if typeof value is 'string'
            htmlContent = htmlContent + '<b>' + key + ': </b>' + value + '<br /><br />'
          if typeof value is 'object'
            if value.length == undefined
              htmlContent = htmlContent + '<b>' + key + ': </b><br />'
              for own key2, value2 of value
                if typeof value2 is 'string'
                  value2 = value2.replace(/<\/?[^>]+(>|$)/g, "");
                  htmlContent = htmlContent + '<u>' + key2 + ': </u>' + value2 + '<br />'
              htmlContent = htmlContent + '<br />'
      htmlContent = '<div style="padding: 8px;">' + htmlContent + '</div>'
      tooltip.DOM.innerHTML = htmlContent
      tooltip.autoSize()
    )

    return


  #######################################################################
  # handle suggestions-menu  (POPOVER)
  #######################################################################
  __updateSuggestionsMenu: (cdata, cdata_form, suggest_Menu, searchsuggest_xhr) ->
    that = @

    delayMillisseconds = 200

    setTimeout ( ->

        tnadiscovery_searchstring = cdata_form.getFieldsByName("searchbarInput")[0].getValue()
        tnadiscovery_searchstring = '"' + encodeURIComponent(tnadiscovery_searchstring) + '"'
        tnadiscovery_searchstring = encodeURIComponent(tnadiscovery_searchstring)
        tnadiscovery_countSuggestions = cdata_form.getFieldsByName("countOfSuggestions")[0].getValue()

        if tnadiscovery_searchstring.length < 2
            return

        # run autocomplete-search via xhr
        if searchsuggest_xhr.xhr != undefined
            # abort eventually running request
            searchsuggest_xhr.xhr.abort()

        # start new request
        url = location.protocol + '//jsontojsonp.gbv.de/?url=http%3A%2F%2Fdiscovery.nationalarchives.gov.uk%2FAPI%2Fsearch%2Fv1%2Frecords%3Fsps.searchQuery%3D' + tnadiscovery_searchstring + '%26sps.sortByOption%3DRELEVANCE%26sps.resultsPageSize%3D' + tnadiscovery_countSuggestions
        searchsuggest_xhr.xhr = new (CUI.XHR)(url: url)
        searchsuggest_xhr.xhr.start().done((data, status, statusText) ->

            extendedInfo_xhr = { "xhr" : undefined }

            # create new menu with suggestions
            menu_items = []
            # the actual Featureclass
            for suggestion, key in data.records
              jsonValue = {}
              jsonValue.discoveryID = suggestion.id
              jsonValue.discoveryURL = 'http://discovery.nationalarchives.gov.uk/details/r/' + suggestion.id
              jsonValue.referenceNumber = suggestion.reference
              jsonValue.locationHeld = suggestion.heldBy[0]
              jsonValue.title = suggestion.title
              jsonValue.description = suggestion.description
              jsonStrValue = JSON.stringify(jsonValue)

              listStr = suggestion.reference + ': ' + suggestion.title
              if listStr.length > 55
                listStr = listStr.substring(0,55)+' ...';

              do(key) ->
                item =
                  text: listStr
                  value: jsonStrValue
                  tooltip:
                    markdown: true
                    placement: "e"
                    content: (tooltip) ->
                      that.__getAdditionalTooltipInfo(suggestion.id, tooltip, extendedInfo_xhr)
                      new CUI.Label(icon: "spinner", text: $$('custom.data.type.tnadiscovery.modal.form.text.loading'))
                menu_items.push item

            # set new items to menu
            itemList =
              onClick: (ev2, btn) ->

                # lock in save data
                jsonStrValue = btn.getOpt("value")
                jsonValue = JSON.parse(jsonStrValue);

                cdata.discoveryID = jsonValue.discoveryID
                cdata.discoveryURL = jsonValue.discoveryURL
                cdata.referenceNumber = jsonValue.referenceNumber
                cdata.locationHeld = jsonValue.locationHeld
                cdata.title = jsonValue.title
                cdata.description = jsonValue.description
                cdata.conceptName = jsonValue.referenceNumber
                cdata.conceptURI = jsonValue.discoveryURL

                # lock in form
                cdata_form.getFieldsByName("title")[0].storeValue(cdata.title).displayValue()
                cdata_form.getFieldsByName("referenceNumber")[0].storeValue(cdata.referenceNumber).displayValue()
                # nach eadb5-Update durch "setText" ersetzen und "__checkbox" rausnehmen
                cdata_form.getFieldsByName("discoveryURL")[0].__checkbox.setText(cdata.discoveryURL)
                cdata_form.getFieldsByName("discoveryURL")[0].show()

                # clear searchbar
                cdata_form.getFieldsByName("searchbarInput")[0].setValue('')
              items: menu_items

            # if no hits set "empty" message to menu
            ###
            if itemList.items.length == 0
              itemList =
                items: [
                  text: " --- "
                  value: undefined
            ###
            suggest_Menu.setItemList(itemList)
            suggest_Menu.show()

        )
    ), delayMillisseconds


  #######################################################################
  # create form (POPOVER)
  #######################################################################
  __getEditorFields: (cdata) ->
    that = @
    fields = []
    # treeview !?
    ## change if!!

    # count of suggestions (not for treeview)
    if ! that.getCustomMaskSettings().use_tree_view?.value
        option =  {
          type: CUI.Select
          class: "commonPlugin_Select"
          undo_and_changed_support: false
          form:
              label: $$('custom.data.type.tnadiscovery.modal.form.text.count')
          options: [
            (
                value: 10
                text: '10 ' + $$('custom.data.type.tnadiscovery.modal.form.text.countX')
            )
            (
                value: 20
                text: '20 ' + $$('custom.data.type.tnadiscovery.modal.form.text.countX')
            )
            (
                value: 50
                text: '50 ' + $$('custom.data.type.tnadiscovery.modal.form.text.countX')
            )
            (
                value: 100
                text: '100 ' + $$('custom.data.type.tnadiscovery.modal.form.text.countX')
            )
          ]
          name: 'countOfSuggestions'
        }
        fields.push option
    # searchfield (autocomplete)
    option =  {
          type: CUI.Input
          class: "commonPlugin_Input"
          undo_and_changed_support: false
          form:
              label: $$("custom.data.type.tnadiscovery.modal.form.text.searchbar")
          placeholder: $$("custom.data.type.tnadiscovery.modal.form.text.searchbar.placeholder")
          name: "searchbarInput"
        }
    fields.push option
    # title
    option =  {
          form:
            label: $$("custom.data.type.tnadiscovery.modal.form.title.label")
          type: CUI.Output
          name: "title"
          data: {title: cdata.title}
        }
    fields.push option

    # referenceNumber
    option =  {
          form:
            label: $$("custom.data.type.tnadiscovery.modal.form.refnumber.label")
          type: CUI.Output
          name: "referenceNumber"
          data: {referenceNumber: cdata.referenceNumber}
        }
    fields.push option
    # discoveryURL
    option =  {
          form:
            label: $$("custom.data.type.tnadiscovery.modal.form.url.label")
          type: CUI.FormButton
          name: "discoveryURL"
          icon: new CUI.Icon(class: "fa-external-link")
          text: cdata.discoveryURL
          onClick: (evt,button) =>
            window.open cdata.discoveryURL, "_blank"
          onRender : (_this) =>
            if cdata.discoveryURL == ''
              _this.hide()
        }
    fields.push option

    fields

  #######################################################################
  # is called, when record is being saved by user
  getSaveData: (data, save_data, opts) ->
    if opts.demo_data
      # return demo data here
      return {
          conceptName : 'conceptName'
          conceptURI : 'conceptURI'
          discoveryID : 'discoveryID'
          discoveryURL : 'http://discoveryURL.tna.org'
          referenceNumber : '123123123'
          locationHeld : 'locationHeld'
          title : 'title title title title'
          description : 'description description description description description description description description description description description description'
      }

    cdata = data[@name()] or data._template?[@name()]

    switch @getDataStatus(cdata)
      when "invalid"
        throw InvalidSaveDataException

      when "empty"
        save_data[@name()] = null

      when "ok"
        save_data[@name()] =
          conceptName : cdata.referenceNumber.trim()
          conceptURI : cdata.discoveryURL.trim()
          discoveryID : cdata.discoveryID.trim()
          discoveryURL : cdata.discoveryURL.trim()
          referenceNumber : cdata.referenceNumber.trim()
          locationHeld : cdata.locationHeld.trim()
          title : cdata.title.trim()
          description : cdata.description.trim()
          #_fulltext:
          #        text: cdata.title.trim() + ' ' + cdata.description.trim() + ' ' + cdata.referenceNumber.trim() + ' ' + cdata.discoveryID.trim()
          #        string: cdata.title.trim() + ' ' + cdata.description.trim() + ' ' + cdata.referenceNumber.trim() + ' ' + cdata.discoveryID.trim()


  #######################################################################
  # checks the form and returns status
  getDataStatus: (cdata) ->
    if (cdata)
        if cdata.referenceNumber and cdata.title

          if cdata.referenceNumber != '' and cdata.title != ''
            return "ok"
          else
            return "empty"

        else
          cdata = {
                  conceptName : ''
                  conceptURI : ''
                  discoveryID : ''
                  discoveryURL : ''
                  referenceNumber : ''
                  locationHeld : ''
                  title : ''
                  description : ''
            }
          return "empty"
    else
      cdata = {
            conceptName : ''
            conceptURI : ''
            discoveryID : ''
            discoveryURL : ''
            referenceNumber : ''
            locationHeld : ''
            title : ''
            description : ''
        }
      return "empty"


  #######################################################################
  # renders details-output of record
  renderDetailOutput: (data, top_level_data, opts) ->
    @__renderButtonByData(data[@name()])


  #######################################################################
  # renders the "result" in original form (outside popover)
  __renderButtonByData: (cdata) ->

    that = @
    # when status is empty or invalid --> message

    switch @getDataStatus(cdata)
      when "empty"
        return new CUI.EmptyLabel(text: $$("custom.data.type.tnadiscovery.edit.no_tnadiscovery")).DOM
      when "invalid"
        return new CUI.EmptyLabel(text: $$("custom.data.type.tnadiscovery.edit.no_valid_tnadiscovery")).DOM

    # output Result of picked tnadiscovery-Entry

    list = new CUI.VerticalList
      maximize: false
      content: [
        new CUI.Label
          text: " "
        new CUI.ButtonHref
          name: "outputButtonHref"
          appearance: "important"
          href: cdata.discoveryURL
          target: "_blank"
          icon_left: new CUI.Icon(class: "fa-external-link")
          text: cdata.discoveryURL
        new CUI.Label
          text: cdata.title
          multiline: true
          manage_overflow: true
        new CUI.Label
          text: '[' + cdata.referenceNumber + ']'
          multiline: true
          manage_overflow: true
        new CUI.Label
          text: cdata.description
          multiline: true
          manage_overflow: true
        new CUI.Label
          text: '[' + cdata.locationHeld + ']'
          multiline: true
          manage_overflow: true
      ]

    list.DOM


  #######################################################################
  # update result in Masterform
  __updateResult: (cdata, layout) ->
    btn = @__renderButtonByData(cdata)
    layout.replace(btn, "bottom")


  #######################################################################
  # buttons, which open and close popover
  __renderEditorInputPopover: (data, cdata) ->

    layout = new CUI.VerticalLayout
      top:
        content:
            new CUI.Buttonbar(
              buttons: [
                  new CUI.Button
                      text: ""
                      icon: 'edit'
                      group: "groupA"

                      onClick: (ev, btn) =>
                        @showEditPopover(btn, cdata, layout)

                  new CUI.Button
                      text: ""
                      icon: 'trash'
                      group: "groupA"
                      onClick: (ev, btn) =>
                        # delete data
                        cdata = {
                            conceptName : ''
                            conceptURI : ''
                            discoveryID : ''
                            discoveryURL : ''
                            referenceNumber : ''
                            locationHeld : ''
                            title : ''
                            description : ''
                        }
                        data[@name()] = cdata
                        # trigger form change
                        @__updateResult(cdata, layout)
                        CUI.Events.trigger
                          node: @__layout
                          type: "editor-changed"
                        CUI.Events.trigger
                          node: layout
                          type: "editor-changed"
              ]
            )
      center: {}
      bottom: {}
    @__updateResult(cdata, layout)
    layout

  #######################################################################
  # zeige die gewählten Optionen im Datenmodell unter dem Button an
  getCustomDataOptionsInDatamodelInfo: (custom_settings) ->
    tags = []

    tags


CustomDataType.register(CustomDataTypeTNADiscovery)