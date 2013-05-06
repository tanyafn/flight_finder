class SearchesController < ApplicationController
  before_filter :build_params, only: :create

  def new
    @search = Search.new
  end

  def create
    @search = Search.new params[:search]
    render :new and return if @search.invalid?
    @itineraries = Itinerary.find_by(@search)
    rescue Exception => e
      @err = e
  end

  def build_params
    params[:search][:date] = Date.new(*params[:search].sort.map(&:last).map(&:to_i).first(3)) unless params[:search][:date]
    (1..3).each{ |num| params[:search].delete("date(#{num}i)")}
  end

end