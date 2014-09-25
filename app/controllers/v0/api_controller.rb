# Copyright (c) 2014 Public Library of Science
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module V0
  class ApiController < ::ApiController

    before_action :authentication_required!, :except => [ :show ]
    before_action :paper_required, except: [:create]
    protect_from_forgery with: :null_session

    def create
      respond_to do |format|
        format.json do
          metadata = uploaded_metadata
          uri      = metadata['uri']

          render status: :forbidden,      text:'Paper already exists' and return if Paper.exists?(uri: uri)

          paper = Paper.new

          if paper.update_metadata( metadata, authenticated_user )
            render text:'Document Created', status: :created
          else
            render text:'Invalid Metadata', status: :unprocessable_entity
          end
        end
      end
    end

    def show
      respond_to do |format|
        format.json do
          include_cited = 'cited'.in?(includes)
          render  json: @paper.metadata(include_cited)
        end
      end
    end

    private

    def includes
      params[:include] ? params[:include].split(',') : []
    end

    def paper_required
      uri = URI.decode_www_form_component( params[:id] )
      @paper = Paper.for_uri(uri)
      render(status: :not_found, text: 'Not Found') unless @paper
      @paper
    end

    def uploaded_metadata
      JSON.parse(request.body.read)
    end

  end
end
