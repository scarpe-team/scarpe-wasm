require "scarpe/wasm_local"

Shoes.app do
  stack do
    para "Here I am"
    button "Push me"
    alert "I am an alert!"
    #edit_line "edit_line here", width: 450
    #image "http://shoesrb.com/manual/static/shoes-icon.png"
  end
end
