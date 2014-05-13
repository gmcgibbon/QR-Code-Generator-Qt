# QR Code Generator
# Generates QR Codes from passed strings
# qr_app_qt.rb
# 
# Gannon McGibbon
# Date Created: 12/05/2014
# Last Updated: 12/05/2014

require 'HTTParty'
require 'Qt4'
require 'ostruct'


URL   = "https://api.qrserver.com/v1/create-qr-code/"
SIZE  = "150x150"
QUERY = "?size=#{SIZE}&data=" # append data contents

MAIN_IMAGE_PATH = "./assets/img/qr_main.png"
MAIN_ICON_PATH  = "./assets/img/qr_icon.png"
QR_OUTPUT_PATH  = "./assets/qr/code.png"


# QR Code Generating App in Ruby Qt!
class QRAppQt < Qt::Application

  # Constructor
  def initialize
    # Run super constructor using passed args
    super ARGV

    # QR image pixmap
    @qr_img        = Qt::Pixmap.new(MAIN_IMAGE_PATH)
    # QR image label
    @qr_img_label  = Qt::Label.new()
    # QR data label
    @qr_data_label = Qt::Label.new("Give it a try!")
    # Gen data label
    @data_label    = Qt::Label.new("QR Code Data:")
    # Gen data textbox
    @data_edit     = Qt::LineEdit.new()
    # Query button
    @query_button  = Qt::PushButton.new("Generate")
    # Close button 
    @quit_button   = Qt::PushButton.new("Quit")
    # Main form
    @main_widget   = build_widget

    # Setup panel
    @main_widget.layout.add_widget(@qr_img_label,  0, Qt::AlignCenter)
    @main_widget.layout.add_widget(@qr_data_label, 0, Qt::AlignCenter)
    @main_widget.layout.add_widget(@data_label,    0, Qt::AlignLeft)
    @main_widget.layout.add_widget(@data_edit,     0, Qt::AlignLeft)
    @main_widget.layout.add_widget(@query_button,  0, Qt::AlignRight)
    @main_widget.layout.add_widget(@quit_button,   0, Qt::AlignRight)

    # Add listeners and configuration
    wire_widget
  end

  # Runs execution code to display form
  def run
    # Evaluate any launch params
    if ARGV.any?
      # Set data text to params joined by spaces
      @data_edit.set_text(ARGV.join ' ')
    end
    # Show main widget and execute application
    @main_widget.show
    self.exec
  end

  protected

  # Generates the QR code via an API call
  def gen_qr_code data
    begin
      # Form query
      query = "#{URL}#{QUERY}#{data}"
      # Write file to output path
      File.open(QR_OUTPUT_PATH, "wb") do |file| 
        file.write HTTParty.get(URI.escape query).parsed_response
      end
      # Update UI
      @qr_img_label.set_pixmap(Qt::Pixmap.new(QR_OUTPUT_PATH))
      @qr_data_label.set_text(data)
    rescue => e
      puts e.inspect
      title = "QR Error"
      error = "Error: \"#{data}\" could not be rendered as QR Code!"
      build_message_box(title, error)
    end
  end

  # Builds a new Widget object
  def build_widget
    Qt::Widget.new do
      # Widget Properties
      self.window_title = "QR Generator Qt"
      self.maximum_size = Qt::Size.new(500, 500)
      self.minimum_size = Qt::Size.new(300, 400)

      self.resize self.minimum_size
      
      self.set_window_icon Qt::Icon.new(MAIN_ICON_PATH)
      # Widget layout
      self.layout = Qt::VBoxLayout.new
    end
  end

  # Builds a new error MessageBox object
  def build_message_box title, message
    Qt::MessageBox.new do
      # MessageBox Properties
      self.window_title = title
      self.set_text(message)
      self.exec
    end
  end

  # Configure individual form controls
  def wire_widget
    # Add listeners
    @query_button.connect(SIGNAL :clicked) do
      gen_qr_code @data_edit.text
    end
    @quit_button.connect(SIGNAL  :clicked) do
      QRAppQt.quit
    end

    # Add pixmap to label
    @qr_img_label.set_pixmap(@qr_img)

    # Set default button
    @query_button.set_default(true)
  end
end
