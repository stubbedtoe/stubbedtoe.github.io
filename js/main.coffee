---
---

$filter_links = null
$blocks = null
$initial = true
$ajax = null
$interior = null
categories = {}
is_mobile = false
is_one_column = false
TO = false
home_page = true
overlay_showing = false
$foto = null
fotorama = null
current_overlay = false
selected_block = false
block_data = {}
text_data = {}
pos_to_id = {}
id_to_pos = {}

fullscreen_open = false
$current_showing = null

pos_to_elem = {}
fullscreen_open = false


toggle_blur_active = (obj, to_add, to_remove) ->
    obj.removeClass to_remove
    obj.addClass to_add unless obj.hasClass to_add 

toggle_ajax = (obj=null) ->
    
    if overlay_showing
        if one_column()
            $ajax.after(selected_block)
        $ajax.hide() 
    else 
        $ajax.show()    
    return not overlay_showing

and_or = (is_and) ->

    $blocks.each (index) ->

        matching_cats = ($(this).hasClass key for key, val of categories when val)

        if (is_and and all matching_cats) or (not is_and and any matching_cats)
            toggle_blur_active $(this), 'active', 'blur'
        else
            toggle_blur_active $(this), 'blur', 'active'
        true

    true


any = (array) -> true in array
all = (array) -> false not in array

one_column = -> Modernizr.mq '(max-width: 480px)'#document.body.clientWidth < 480
#mobile = -> document.body.clientWidth < 768
mobile = -> Modernizr.mq '(max-width: 768px)'
two_column = -> Modernizr.mq '(max-width: 1140px)'# and not one_column()#document.body.clientWidth < 1140 and not one_column()
three_column = -> Modernizr.mq '(min-width: 1140px)'#document.body.clientWidth >= 1140


blur_unblur = ->

    any_selected = any (val for key, val of categories)
    
    if any_selected
        and_or $('#and').hasClass 'active'  
    else
        $blocks.removeClass 'blur'
        $blocks.removeClass 'active'


switch_link = (obj, category_name) ->

    obj.toggleClass 'active'
    categories[category_name] = obj.hasClass 'active'
    blur_unblur()

parse_query_string = ->

    category_keys = []
    $('#categories li').each (index) ->
        category = $(this).text().substring 2
        categories[category] = false
        category_keys.push category
        true

    if home_page 
        base = ""
    else 
        base = window.location.href.split "/filter/"
        base = if base.length > 1 then base[1]
    
    #parse filter string

    query = if window.location.search.length then window.location.search.substring 1 else ""

    unless (query.indexOf "-") is -1
        #or precedence
        requested = (cat for cat in query.split '-' when cat.toLowerCase() in category_keys)
    else unless (query.indexOf "+") is -1   
        $('#and').toggleClass 'active'
        $('#or').toggleClass 'active'
        requested = (cat for cat in query.split '+' when cat.toLowerCase() in category_keys)
    else
        requested = if query in category_keys then [query] else []

    switch_link $('#'+category_name), category_name for category_name in requested

get_top_offset  = (obj) ->

    #from https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollY
    supportPageOffset = window.pageXOffset isnt undefined
    isCSS1Compat = document.compatMode is "CSS1Compat"

    y = if supportPageOffset then window.pageYOffset else 
        if isCSS1Compat then document.documentElement.scrollTop else document.body.scrollTop

    fixed_top = $('#fixed-top').height()

    if is_mobile and document.body.clientWidth < 480 #position: static
        if y < fixed_top
            console.log "smallest and #{fixed_top}"
            return fixed_top
        else
            console.log "smallest and #{fixed_top} + #{y}"
            return fixed_top + y
    else 
        if y < obj.parent().offset().top 
            return 0 
        else if is_mobile #two-column
            return fixed_top + y - obj.parent().offset().top
        else 
            return y - obj.parent().offset().top

show_ajax = (obj) ->

    id = obj.attr 'id'
    while fotorama.size > 0
        fotorama.pop()
    fotorama.load block_data[id]

    # save what's currently displaying to cache 
    if current_overlay
        text_data[current_overlay] = $("#interior h3, 
                                        #interior #medium,
                                        #interior #description,
                                        #interior #tech").detach()  

    
    if $ajax.hasClass id
        # use our cache
        $interior.append text_data[id]
    else
        $.ajax
            url: "/projects/#{id}.html"
            dataType: 'html'
            success: (data, txt, xhr) ->
                response = $('<html />').html data

                $interior.append response.find ".exterior h3"
                $interior.append response.find ".exterior #medium"
                $interior.append response.find ".exterior #description"
                $interior.append response.find ".exterior #tech"
                $ajax.addClass id

    position =  parseInt $current_showing.attr 'data-pos'
    if not position
        throw "position is Nan"
    last = position is $blocks.size()
    columns = if one_column() then 1 else if two_column() then 2 else 3
    $visi_blocks = $('.block:visible')

    console.log ('position: '+position)
    console.log ('columns: '+columns)
    #console.log ('current_showing: '+current_showing)
    # where to place the ajax element?

    #very particular case dealing with invisible blocks
    if columns is 2 and $visi_blocks.size() < $blocks.size()     
        position = $visi_blocks.index(obj) + 1
        last = position is $visi_blocks.size()
        unless position % 2 is 0 or last
            $current_showing.nextAll('.block:visible').first().after($ajax)
    # last in row
    else if columns is 1 or (columns is 2 and position % 2 is 0) or (columns is 3 and position % 3 is 0) or last
        $current_showing.after($ajax)
    # first in row - 2-column OR middle in row - 3-column
    else if columns is 2 or (columns is 3 and position % 3 is 2) 
        $current_showing.next().after($ajax)
    # first in row 3-column
    else 
        $current_showing.next().next().after($ajax)

    $ajax.show()
    return id

enter_fullscreen = -> fotorama.requestFullScreen() 

project_requested =  (obj) ->
    try
        current_overlay = show_ajax obj
    catch error
        console.log 'error caught: '+error
        overlay_showing = toggle_ajax()
    $(window).resize()

prev_next = (which) ->
    try
        temp = pos_to_id[id_to_pos[current_overlay]][which]
        target_id = pos_to_id[temp]['id']
        $target = $('#'+target_id)
        console.log (which + ' called ' + target_id)
        project_requested $target
    
    catch error
        overlay_showing = toggle_ajax()



#############
# interaction
#############

    
#################
# resize stuff

on_resize = ->

    is_mobile = mobile()
    is_one_column = one_column()
   

$(window).resize ->
 if TO
    clearTimeout(TO);
 TO = setTimeout on_resize, 200 #time in milliseconds

################

#close overlay when it loses focus

$(document).mouseup (e) ->
  if $(e.target).hasClass 'block'
    unless overlay_showing
        current_overlay = show_ajax $(e.target)
    else
        console.log 'already open'  
  else if overlay_showing and !$ajax.is(e.target) and $ajax.has(e.target).length == 0
    overlay_showing = toggle_ajax()
  return


$('.block').click -> 

    overlay_showing = toggle_ajax $(this)
    $current_showing = $(this)
    project_requested $(this)
      
$('#prev-ajax').click -> 
    prev_next 'prev'       

$('#next-ajax').click -> 
    prev_next 'next'


$('#close-ajax').click -> overlay_showing = toggle_ajax()

$('#and, #or').click -> 
    
    $('#or, #and').toggleClass 'active'
    blur_unblur()

$("#categories li a").click -> 

    category_name = $(this).parent().attr 'id'

    if is_mobile
        categories = (key[false] for key, val of categories) #don't do combinations of categories
        categories[category_name] = true
        console.log categories
        and_or false #go straight to the blurring/unblurring

    else
        switch_link $(this).parent() , category_name

################### end interaction

# document ready function
$ ->
    
    is_mobile = mobile()
    is_one_column = one_column()
    home_page = window.location.pathname is "/"

    $blocks = $('.block')
    $ajax = $('#ajax')
    $interior = $('#interior')
        
    
    #fotorama_data = fotorama.data

    #remove links to project pages
    $('.block a').each (index) ->
        parent = $(this).parent()
        $(this).replaceWith $(this).children()
        id = parent.attr 'id'
        block_data[id] = []
        pos = (parseInt (parent.attr 'data-pos'))
        id_to_pos[id] = pos
        data = {'id':id, 'prev': (parseInt (parent.attr 'data-prev')), 'next': (parseInt (parent.attr 'data-next'))}
        pos_to_id[pos]= data

        #console.log (pos_to_id[(parseInt (parent.attr 'data-pos'))])
       

    $('#fotorama a').each (index) ->
        id = $(this).attr 'class'
        type = $(this).attr 'data-type'
        if type is 'video'
            block_data[id].push 
                video: $(this).attr 'href'
        else
            block_data[id].push 
                img: $(this).attr 'href'
                full: $(this).attr 'data-full'
                caption: if $(this).attr 'data-caption' then $(this).attr 'data-caption' else ''
        true

    #replace img tags as a
    $('#fotorama img').each (index) ->
        url = $(this).attr 'src'
        caption = if $(this).attr 'data-caption' then $(this).attr 'data-caption' else '' 
        $(this).replaceWith "<a href='#{url}' data-caption='#{caption}'></a>"
        true

    $('#fotorama iframe').each (index) ->
        url = $(this).attr 'alt'
        $(this).replaceWith "<a href='#{url}'></a>"


    $('#fotorama').on 'fotorama:show ' + 'fotorama:fullscreenenter ' + 'fotorama:fullscreenexit',  (e, fotorama, extra) ->
        
        if e.type is 'fotorama:fullscreenenter'
            fullscreen_open = true
        if e.type is 'fotorama:fullscreenexit'
            fullscreen_open = false 

    
    $foto = $('#fotorama').fotorama() #initialise
    fotorama = $foto.data 'fotorama' #grab api object
    
    $ajax.css 'position', 'relative'
    $ajax.css 'left', 0
    $ajax.hide()
    
    $filter_links = $("#categories li a")

    if home_page
        $filter_links.removeAttr 'href'
        fotorama.destroy()
    else
        $('#and').hide()
        $('#or').hide()
        $filter_links.each (index) ->
            category_name = $(this).parent().attr 'id'
            base = window.location.origin
            $(this).attr 'href', "#{base}?#{category_name}"
            true

    parse_query_string()

    


    

    

