#!/usr/bin/env ruby
require 'gtk3'
require 'open3'

class EmergencyInputApp
  def initialize
    @app = Gtk::Application.new("com.omarchy.emergency.input", :flags_none)

    @app.signal_connect "activate" do |application|
      build_ui(application)
    end
  end

  def run
    @app.run
  end

  private

  def build_ui(application)
    window = Gtk::ApplicationWindow.new(application)
    window.set_title("Emergency JP Input")
    window.set_default_size(600, 400)

    # Main Layout
    vbox = Gtk::Box.new(:vertical, 10)
    vbox.margin_top = 10
    vbox.margin_bottom = 10
    vbox.margin_start = 10
    vbox.margin_end = 10
    window.add(vbox)

    # Instructions
    label = Gtk::Label.new("Type text. Press Ctrl+Enter to Copy & Close.")
    label.halign = :start
    vbox.pack_start(label, :expand => false, :fill => false, :padding => 0)

    # Text Area
    scrolled_window = Gtk::ScrolledWindow.new
    @text_view = Gtk::TextView.new
    @text_view.wrap_mode = :word_char
    @text_view.left_margin = 10
    @text_view.right_margin = 10
    @text_view.top_margin = 10
    @text_view.bottom_margin = 10

    # CSS for larger font
    css_provider = Gtk::CssProvider.new
    css_provider.load_from_data("textview { font-size: 16pt; font-family: Sans; }")
    @text_view.style_context.add_provider(css_provider, Gtk::StyleProvider::PRIORITY_APPLICATION)

    @text_buffer = @text_view.buffer
    scrolled_window.add(@text_view)
    vbox.pack_start(scrolled_window, :expand => true, :fill => true, :padding => 0)

    # Buttons
    bbox = Gtk::Box.new(:horizontal, 10)
    bbox.halign = :end
    vbox.pack_start(bbox, :expand => false, :fill => false, :padding => 0)

    btn_cancel = Gtk::Button.new(:label => "Cancel")
    btn_cancel.signal_connect "clicked" do
      window.close
    end
    bbox.pack_start(btn_cancel, :expand => false, :fill => false, :padding => 0)

    btn_copy = Gtk::Button.new(:label => "Copy (Ctrl+Enter)")
    btn_copy.style_context.add_class("suggested-action")
    btn_copy.signal_connect "clicked" do
      do_copy(window)
    end
    bbox.pack_start(btn_copy, :expand => false, :fill => false, :padding => 0)

    # Key Capture
    # In GTK3, we connect to 'key-press-event' on the window.
    # It returns true to stop propagation.
    window.signal_connect "key-press-event" do |widget, event|
      handle_keypress(window, event)
    end

    window.show_all
  end

  def handle_keypress(window, event)
    keyval = event.keyval
    state = event.state

    # Escape to close
    if keyval == Gdk::Keyval::KEY_Escape
      window.close
      return true
    end

    # Ctrl+Enter
    if state.control_mask?
      if keyval == Gdk::Keyval::KEY_Return || keyval == Gdk::Keyval::KEY_KP_Enter
        do_copy(window)
        return true
      end
    end

    false
  end

  def do_copy(window)
    # Correct method for Gtk::TextBuffer is get_text
    start_iter = @text_buffer.start_iter
    end_iter = @text_buffer.end_iter
    text = @text_buffer.get_text(start_iter, end_iter, true)
    
    if text && !text.empty?
      begin
        # Use IO.popen for cleaner piping to wl-copy
        IO.popen(['wl-copy'], 'w') do |io|
          io.write(text)
        end
        # Use spawn for notify-send to avoid blocking
        pid = spawn("notify-send", "Copied!", "Text saved to clipboard.")
        Process.detach(pid)
      rescue => e
        puts "Error: #{e.message}"
      end
    end

    window.close
  end
end

EmergencyInputApp.new.run
