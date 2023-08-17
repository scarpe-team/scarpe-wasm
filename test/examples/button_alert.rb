require "scarpe/wasm_local"

Shoes.app do
  @push = button "Push me"
  @push.click {
    alert "Aha! Click!"
  }
end
