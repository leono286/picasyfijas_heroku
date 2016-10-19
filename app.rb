require "sinatra"
require 'sinatra/cookies'
require 'encrypted_strings'
# require_relative 'lib/picas_fijas_class'

get '/' do
	pwd = "1234tratando"
	@win = 0
	@ntries = 0
	@res = ""
	#Generate number
	my_number_array = []
	list_of_number = (0..9).to_a
	4.times do
	  digit = list_of_number.sample
	  my_number_array.push(digit)
	  list_of_number.delete(digit)
	end
	puts my_number_array.inspect
	my_number_array = my_number_array.join("&").encrypt(:symmetric, :algorithm => 'des-ecb', :password => pwd)
	puts my_number_array
	response.set_cookie(:number, value: my_number_array)
	erb :index
end


post '/' do
	pwd = "1234tratando"
	@res = params[:res]
	# @res = 
	@ntries = params[:ntries].to_i + 1
	fijas_count = 0
	picas_count = 0	
	my_number_array = cookies[:number].decrypt(:symmetric, :algorithm => 'des-ecb', :password => pwd).split('&').map(&:to_i)
	user_num = params[:number].split("").map(&:to_i)	
	if user_num.length > 0
		if user_num.length != 4
			@res = params[:number] + "-" + "88," + @res
		else
			if user_num.uniq.length == user_num.length
				i = 0
				while i < user_num.length
					if my_number_array[i] == user_num[i]
						fijas_count += 1
					elsif my_number_array.include? user_num[i]
						picas_count += 1
					end
					i += 1
				end
				@res = params[:number] + "-" + picas_count.to_s + fijas_count.to_s + "," + @res
			else
				@res = params[:number] + "-" + "99," + @res
			end
		end
	end
	
	if (fijas_count == 4)
		@win = 1
	else
		@win = 0
	end
	erb :index
end

