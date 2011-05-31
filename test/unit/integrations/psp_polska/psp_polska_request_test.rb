require 'test_helper'
require 'psp_polska_test_helper'
require 'digest/md5'

class PspPolskaRequestTest < ActiveSupport::TestCase
  include ActiveMerchant::Billing::Integrations::PspPolska

  def setup
    Time.stubs(:now).returns(555)
    @request = PspPolskaRequest.new(VALID_SALE_REQUEST_PARAMS)
    @confirmation_request = PspPolskaRequest.new(VALID_CONFIRMATION_REQUEST_PARAMS)
    @recurring_start_request = PspPolskaRequest.new(VALID_RECURRING_START_REQUEST_PARAMS)
    @recurring_stop_request = PspPolskaRequest.new(VALID_RECURRING_STOP_REQUEST_PARAMS)
    @recurring_confirmation_request = PspPolskaRequest.new(VALID_RECURRING_CONFIRMATION_REQUEST_PARAMS)
  end

  def test_params_after_initialize
    assert @request.params.has_key?(:version)
    PSP_POLSKA_REQUEST_CHECKSUM_FIELDS.each do |key|
      assert @request.params.has_key?(key)
    end
    assert !@request.params.has_key?(:fake)
    assert @confirmation_request.params.has_key?(:version)
    PSP_POLSKA_CONFIRMATION_REQUEST_CHECKSUM_FIELDS.each do |key|
      assert @confirmation_request.params.has_key?(key)
    end
    assert !@confirmation_request.params.has_key?(:fake)
    assert @recurring_start_request.params.has_key?(:version)
    PSP_POLSKA_RECURRING_START_REQUEST_CHECKSUM_FIELDS.each do |key|
      assert @recurring_start_request.params.has_key?(key)
    end
    assert !@recurring_start_request.params.has_key?(:fake)
    assert @recurring_stop_request.params.has_key?(:version)
    PSP_POLSKA_RECURRING_STOP_REQUEST_CHECKSUM_FIELDS.each do |key|
      assert @recurring_stop_request.params.has_key?(key)
    end
    assert !@recurring_stop_request.params.has_key?(:fake)
    assert @recurring_confirmation_request.params.has_key?(:version)
    PSP_POLSKA_RECURRING_CONFIRMATION_REQUEST_CHECKSUM_FIELDS.each do |key|
      assert @recurring_confirmation_request.params.has_key?(key)
    end
    assert !@recurring_confirmation_request.params.has_key?(:fake)
  end

  def test_calculate_checksum
    @request.calculate_checksum
    assert_equal @request.params[:checksum], Digest::MD5.hexdigest("999999991salesome_session_id100JohnSmith127.0.0.1555TestRequest1")
    @confirmation_request.calculate_checksum
    assert_equal @confirmation_request.params[:checksum], Digest::MD5.hexdigest("999999991get_status666555TestRequest1")
    @recurring_start_request.calculate_checksum
    assert_equal @recurring_start_request.params[:checksum], Digest::MD5.hexdigest("999999991recurring_startsome_session_id100JohnSmith127.0.0.1555TestRequest1")
    @recurring_stop_request.calculate_checksum
    assert_equal @recurring_stop_request.params[:checksum], Digest::MD5.hexdigest("999999991recurring_stop777555TestRequest1")
    @recurring_confirmation_request.calculate_checksum
    assert_equal @recurring_confirmation_request.params[:checksum], Digest::MD5.hexdigest("999999991recurring_status1234555TestRequest1")
  end

  def test_load_fields_info
    assert_equal @request.instance_variable_get(:@checksum_fields), PSP_POLSKA_REQUEST_CHECKSUM_FIELDS
    assert_equal @confirmation_request.instance_variable_get(:@checksum_fields), PSP_POLSKA_CONFIRMATION_REQUEST_CHECKSUM_FIELDS
    assert_equal @recurring_start_request.instance_variable_get(:@checksum_fields), PSP_POLSKA_RECURRING_START_REQUEST_CHECKSUM_FIELDS
    assert_equal @recurring_stop_request.instance_variable_get(:@checksum_fields), PSP_POLSKA_RECURRING_STOP_REQUEST_CHECKSUM_FIELDS
    assert_equal @recurring_confirmation_request.instance_variable_get(:@checksum_fields), PSP_POLSKA_RECURRING_CONFIRMATION_REQUEST_CHECKSUM_FIELDS
  end

  def test_set_type
    assert_equal @request.set_type("sale"), :request
    assert_equal @request.set_type("get_status"), :confirmation_request
    assert_equal @request.set_type("recurring_start"), :recurring_start_request
    assert_equal @request.set_type("recurring_stop"), :recurring_stop_request
    assert_equal @request.set_type("recurring_status"), :recurring_confirmation_request
    assert_raise(ArgumentError) { @request.set_type("fake")}
  end

end
