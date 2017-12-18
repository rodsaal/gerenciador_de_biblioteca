class LivrosController < ApplicationController
	before_action :verifica_admin, only: [:new, :destroy, :create]
	
	def new
		@livro = Livro.new
	end

	def edit
		@livro = Livro.find(params[:id])
	end

	def update
		livro = Livro.find(params[:id])
		valores = params.require(:livro).permit :titulo, :nome_autor, :qtde_total
		if livro.update valores
			flash[:notice] = "Livro atualizado com sucesso"
			redirect_to dashboard_index_url
		else
			render :new
		end
	end

	def create
		valores = params.require(:livro).permit :titulo, :nome_autor, :qtde_total
		@livro = Livro.create valores
		flash[:notice] = "Livro cadastrado com sucesso"
		redirect_to new_livro_path
	end

	def destroy
		livro = Livro.find(params[:id])
		livro.destroy
		flash[:notice] = "Livro removido com sucesso"
		redirect_to dashboard_index_url
	end

	def aluga
		livro = Livro.find(params[:id])
		if livro.disponivel?
			aluguel = Aluguel.create(livro: livro, user: current_user,
				data: Date.current)
		else
			flash[:error] = "Quantidade indisponível no momento"

		end
		redirect_to dashboard_index_url
	end

	def devolve
		livro = Livro.find(params[:id])
		aluguel = livro.alugueis.where(user: current_user, alugado: true).last
		if aluguel.present?
			aluguel.update(alugado: false, data_devolucao: Date.current)
		else
			flash[:error] = "Você não tem esse livro alugado."

		end
		redirect_to dashboard_index_url
	end

	private

	def verifica_admin
		if !current_user.admin?
			flash[:error] = "Somente o administrador pode cadastrar livros."
			redirect_to dashboard_index_url
		end
	end

end
