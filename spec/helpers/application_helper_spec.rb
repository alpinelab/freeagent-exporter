require "rails_helper"

describe ApplicationHelper, "#flash_class(level)", type: :helper do
  it "returns a css class to color bootstrap alerts according to flash message type" do
    expect(helper.flash_class("notice")).to  eq "alert-info"
    expect(helper.flash_class("success")).to eq "alert-success"
    expect(helper.flash_class("alert")).to   eq "alert-warning"
    expect(helper.flash_class("error")).to   eq "alert-danger"
  end
end
