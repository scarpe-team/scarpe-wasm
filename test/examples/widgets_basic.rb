require "scarpe/wasm_local"

Shoes.app do
  stack do
    para "Here I am"
    button "Push me"
    alert "I am an alert!"
    edit_line "edit_line here", width: 450

    # Image has a conflict in Lacci because of image size
    #image "http://shoesrb.com/manual/static/shoes-icon.png"
  end
  flow do
    arc(400, 0, 120, 100, 175, 175)
    check
    edit_box("bar")
    line(0, 0, 100, 100)
    list_box(items: ['A', 'B'])
    radio("gaga")
    shape { line(0, 0, 10, 10) }
    star(230, 100, 6, 50, 25)
    video("http://techslides.com/demos/sample-videos/small.mp4")
  end
end
