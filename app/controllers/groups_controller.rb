# frozen_string_literal: true

# customer facing controller for groups
class GroupsController < ApplicationController
  def index
    @groups = Group.all
  end

  def show
    @group = Group.find(params[:id])
  end
end
