# frozen_string_literal: true

module Api
  module V1
    # API to deal w users
    class ElectionsController < ApplicationController
      def list_open_elections
        elections = Election.open.for_user(@user).to_a
        render json: { success: true,
                       data: {
                         elections: elections.map do |el|
                           { id: el.id,
                             name: el.name,
                             description: el.description,
                             open_datetime: el.open_datetime,
                             close_datetime: el.open_datetime,
                             choices: el.election_choices.map do |ec|
                               { id: ec.id,
                                 name: ec.name }
                             end,
                             my_vote: begin ev = ElectionVote.joins(:election_choice)
                                                             .where(['user_id = ? and election_choices.election_id = ?',
                                                                     @user.id,
                                                                     el.id]).first
                                            if ev
                                              { choice_id: ev.election_choice.id,
                                                choice_name: ev.election_choice.name }
                                            end
                             end }
                         end
                       } }
      rescue StandardError => e
        render_json({ success: false,
                      error: e.message })
      end

      def vote_in_election
        # user = User.find_by(id: params[:id])
        election = Election.where(id: params[:election_id]).open.for_user(@user).first
        raise 'No such open election for you at current time and current credibility' unless election

        raise 'Election not open yet' if election.open_datetime >= DateTime.now
        raise 'Election already closed' if election.close_datetime <= DateTime.now
        raise 'Election already finalized' if election.finalized

        choice = ElectionChoice.find_by(id: params[:choice_id])
        raise 'No such choice for election' unless choice.election == election

        vote = ElectionVote.joins(:election_choice).find_by(['user_id = ? and election_choices.election_id = ?',
                                                             @user.id, election.id])

        if vote
          vote.update!(election_choice: choice)
          render_json({ success: true,
                        message: 'updated existing vote' })
        else
          ElectionVote.create!(user: @user, election_choice: choice)
          render_json({ success: true,
                        message: 'created vote' })
        end
      rescue StandardError => e
        render_json({ success: false,
                      error: e.message })
      end
    end
  end
end
