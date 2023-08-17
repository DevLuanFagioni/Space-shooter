local composer = require('composer')

local cena = composer.newScene( )

function cena:create( event )
	local grupoCenaJogo = self.view

	local x, y = display.contentWidth, display.contentHeight
	local t = (x + y) / 2

	local physics = require('physics')
	physics.start()
	physics.setGravity( 0, 0 )
	physics.setDrawMode( 'hybrid' )

	local grupoFundo = display.newGroup( )

	local grupoJogo = display.newGroup( ) 

	local grupoGUI = display.newGroup( )

	local vidas = 3

	local vidaIcone1 = display.newImageRect(grupoCenaJogo, 'recursos/imagens/nave.png', t*0.1, t*0.1)
	vidaIcone1.x = x*0.1
	vidaIcone1.y = y*0.95
	grupoGUI:insert(vidaIcone1)

	local vidaIcone2 = display.newImageRect(grupoCenaJogo, 'recursos/imagens/nave.png', t*0.1, t*0.1)
	vidaIcone2.x = x*0.28
	vidaIcone2.y = y*0.95
	grupoGUI:insert(vidaIcone2)

	local vidaIcone3 = display.newImageRect(grupoCenaJogo, 'recursos/imagens/nave.png', t*0.1, t*0.1)
	vidaIcone3.x = x*0.46
	vidaIcone3.y = y*0.95
	grupoGUI:insert(vidaIcone3)

	local pontos = 0

	local pontosTexto = display.newText(grupoCenaJogo, pontos, x*0.85, y*0.95, native.systemFontBold, t*0.1 )
	grupoGUI:insert(pontosTexto)

	local pontosIcone = display.newImageRect(grupoCenaJogo, 'recursos/imagens/asteroide.png', t*0.1, t*0.1)
	pontosIcone.x = x*0.7
	pontosIcone.y = y*0.95
	grupoGUI:insert(pontosIcone)

	local tabelaAsteroide = {}

	local fundo = display.newImageRect(grupoCenaJogo, 'recursos/imagens/fundo.png', x, y )
	fundo.x = x*0.5
	fundo.y = y*0.5
	grupoFundo:insert(fundo)

	local nave = display.newImageRect( grupoCenaJogo, 'recursos/imagens/nave.png', t*0.2, t*0.2 )
	nave.id = 'naveC'
	nave.x = x*0.5
	nave.y = y*0.8
	grupoJogo:insert(nave)
	physics.addBody( nave, 'static', {radius = t*0.08} )


	nave:addEventListener( 'touch', function( event )
		if (event.phase == 'began') then
			display.currentStage:setFocus( nave )
			nave.touchOffsetX = event.x - nave.x

		elseif (event.phase == 'moved') then
			nave.x = event.x - nave.touchOffsetX

		elseif (event.phase == 'ended' or event.phase == 'cancelled') then
			display.currentStage:setFocus( nil )
		end
 	end)


 	nave:addEventListener('touch', function( event )
 		if (event.phase == 'began') then
 			
 			if (vidas > 0) then
 				local laser = display.newImageRect( 'recursos/imagens/laser.png', t*0.05, t*0.1  )
	 			laser.id = 'laserC'
	 			laser.x = nave.x
	 			laser.y = nave.y - nave.height*0.7
	 			physics.addBody( laser, 'dynamic' )
	 			grupoJogo:insert( laser )

	 			transition.to( laser, {time = 500, y = -y*0.5, onComplete = function()
	 				display.remove( laser )
	 			end} )
 			end
 			
 		end
 	end)


 	function criaAsteroide()
 		if (vidas > 0) then
 			local asteroide = display.newImageRect( grupoCenaJogo, 'recursos/imagens/asteroide.png', t*0.15, t*0.15 )
	 		asteroide.id = 'asteroideC'
	 		table.insert(tabelaAsteroide, asteroide)
	 		physics.addBody( asteroide, 'dynamic', {bounce = 0.6, radius = t*0.07} )
	 		grupoJogo:insert(asteroide)

	 		local aleatorio = math.random(1,3)

	 		if (aleatorio == 1) then
	 			asteroide.x = math.random( x )
	 			asteroide.y = -y*0.3
	 			asteroide:setLinearVelocity( 0, t*0.1 )

	 		elseif (aleatorio == 2) then
	 			asteroide.y = -y*0.3
	 			asteroide.x = -x*0.3
	 			asteroide:setLinearVelocity(t*0.1, t*0.1)

	 		elseif (aleatorio == 3) then
				asteroide.y = -y*0.3
				asteroide.x = x + x*0.3
				asteroide:setLinearVelocity(-t*0.1, t*0.1)
	 		end

	 		asteroide:applyTorque( math.random( -t*0.1, t*0.1 ) )
 		end
 	end
 	timer.performWithDelay( 500, criaAsteroide, 0 )

 	function removeAsteroide()
 		for i = #tabelaAsteroide, 1, -1 do
 			if (tabelaAsteroide[i].y > y*1.2 ) then
 				display.remove( tabelaAsteroide[i] )
 				table.remove( tabelaAsteroide, i )
 			end
 		end
 	end
 	Runtime:addEventListener( 'enterFrame', removeAsteroide )


 	function verificaColisao( event )
 		if (event.phase == 'began') then
 			
 			local objeto1 = event.object1
 			local objeto2 = event.object2

 			-- inicio colisao nave e asteroide
 			if (objeto1.id == 'naveC' and objeto2.id == 'asteroideC' or objeto1.id == 'asteroideC' and objeto2.id == 'naveC') then
 				if (vidas > 0) then
 					vidas = vidas - 1

	 				local transicao = transition.blink( nave, {time = 500} )

	 				timer.performWithDelay(1000, function()
	 					transition.pause( transicao )
	 					nave.alpha = 1
	 				end, 1 )
 				end
 			end
 			-- fim colisao nave e asteroide


 			-- inicio colisao laser e asteroide
 			if (objeto1.id == 'laserC' and objeto2.id == 'asteroideC') then
 				
 				pontos = pontos + 1
 				pontosTexto.text = pontos
 				display.remove( objeto1 )

 				for i = #tabelaAsteroide, 1, -1 do
 					if (tabelaAsteroide[i] == objeto2) then
 						transition.blink( tabelaAsteroide[i], {time = 300} )
 						transition.to( tabelaAsteroide[i], {time = 300, xScale = 0, yScale = 0, onComplete = function()
 								display.remove( tabelaAsteroide[i] )
 								table.remove( tabelaAsteroide, i )
 						end} )
 					end
 				end

 			elseif (objeto1.id == 'asteroideC' and objeto2.id == 'laserC') then

 				pontos = pontos + 1
 				pontosTexto.text = pontos
 				display.remove( objeto2 )

 				for i = #tabelaAsteroide, 1, -1 do
 					if (tabelaAsteroide[i] == objeto1) then
 						transition.blink( tabelaAsteroide[i], {time = 300} )
 						transition.to( tabelaAsteroide[i], {time = 300, xScale = 0, yScale = 0, onComplete = function()
 								display.remove( tabelaAsteroide[i] )
 								table.remove( tabelaAsteroide, i )
 						end} )
 					end
 				end

 			end
 			-- fim colisao laser e asteroide

 		end
 	end
 	Runtime:addEventListener( 'collision', verificaColisao )


 	local grupoPontuacao = display.newGroup()

 	local blocoPontuacao = display.newRect( grupoCenaJogo, x*0.5, y*0.5, x*0.9, y*0.7 )
 	blocoPontuacao:setFillColor( 0.2, 0.2, 0.2 )
 	grupoPontuacao:insert(blocoPontuacao)

 	grupoPontuacao.alpha = 0

 	Runtime:addEventListener('enterFrame', function()
		if (vidas == 0) then
			vidaIcone1.alpha = 0
			vidaIcone2.alpha = 0
			vidaIcone3.alpha = 0
			grupoGUI.alpha = 0
			grupoJogo.alpha = 0
			grupoPontuacao.alpha = 1

			grupoPontuacao:insert( pontosTexto )
			pontosTexto.x = x*0.5
			pontosTexto.y = y*0.5

			for i = #tabelaAsteroide, 1, -1 do
				display.remove( tabelaAsteroide[i] )
				table.remove( tabelaAsteroide, i )
			end

		elseif (vidas == 1) then
			vidaIcone1.alpha = 1
			vidaIcone2.alpha = 0
			vidaIcone3.alpha = 0
		elseif (vidas == 2) then
			vidaIcone1.alpha = 1
			vidaIcone2.alpha = 1
			vidaIcone3.alpha = 0
		elseif (vidas == 3) then
			vidaIcone1.alpha = 1
			vidaIcone2.alpha = 1
			vidaIcone3.alpha = 1
		end
	end)

	
end
cena:addEventListener( 'create', cena )
return cena