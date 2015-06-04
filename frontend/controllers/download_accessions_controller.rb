class DownloadAccessionsController < ApplicationController

  set_access_control  "view_repository" => [:download]

  def download
    download_params = {}
    if params['filter_term']
      download_params['filter_term[]'] = Array(params['filter_term'])
    end
    ['q', 'aq'].each{|p| download_params[p] = params[p] if params[p]}

    queue = Queue.new

    Thread.new do
      begin
        JSONModel::HTTP::stream("/repositories/#{session[:repo_id]}/download_accessions",
                                download_params) do |backend_resp|

          response.headers['Content-Disposition'] = backend_resp['Content-Disposition']
          response.headers['Content-Type'] = backend_resp['Content-Type']
          queue << :ok
          backend_resp.read_body do |chunk|
            queue << chunk
          end
        end
      rescue
        queue << {:error => ASUtils.json_parse($!.message)}
      ensure
        queue << :EOF
      end
    end

    first_on_queue = queue.pop
    if first_on_queue.kind_of?(Hash)
      @error = first_on_queue[:error]
      response.headers['Content-Type'] = "text/plain; charset=UTF-8",
      response.headers['Content-Disposition'] = "attachment; filename=\"accessions_#{Time.now.iso8601}.txt\""
      self.response_body = @error.inspect
      return
    end

    self.response_body = Class.new do
      def self.queue=(queue)
        @queue = queue
      end
      def self.each(&block)
        while(true)
          elt = @queue.pop
          break if elt === :EOF
          block.call(elt)
        end
      end
    end

    self.response_body.queue = queue
  end

end
