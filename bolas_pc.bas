' version reducida en resolucion y sin sonidos, para probar en el PC
' de mi version de Android -> https://github.com/jepalza/APP_MisBolas


' 10x14 : nota -> ancho es alto en el movil, al ser pantalla vertical
Dim Shared As Integer ancho=10 ' 10
Dim Shared As Integer alto =14 ' 14

' medidas de las "bolas" (ancho=alto)
Dim Shared As Integer anchobola = 56

Dim Shared As Byte bolas(ancho-1,alto-1)
Dim Shared As Byte bolas_copia(ancho-1,alto-1)
Dim Shared As Integer rand, verif
Dim Shared As Integer x,y
Dim Shared As Integer mx,my,mb
Dim Shared As Integer puntos_total

' graficos
Dim Shared vacio As Any Ptr
'
Dim Shared gris1 As Any Ptr
Dim Shared gris2 As Any Ptr
Dim Shared gris3 As Any Ptr
Dim Shared gris4 As Any Ptr
Dim Shared gris5 As Any Ptr
Dim Shared gris6 As Any Ptr
'
Dim Shared roja  As Any Ptr
Dim Shared verde As Any Ptr
Dim Shared azul  As Any Ptr
Dim Shared cian  As Any Ptr
Dim Shared amari As Any Ptr
Dim Shared morad As Any Ptr

Declare function verifica(mx As Integer, my As Integer) As Integer
Declare Sub limpia_huecos()
Declare function fin_juego() As integer
Declare Sub dibuja()


' pantalla
'ScreenRes (ancho+1)*anchobola, ((alto+1)*anchobola)+50,32
'ScreenRes (1080/escala)+10, (1520/escala)+10,32
Randomize Timer

' comprueba si hay fichas alrededor de nuestra posicion elegida
function verifica(mx As Integer, my As Integer) As Integer
	Dim As Integer x,y,pieza,suma,salir
	Dim As Byte bolas2(ancho+2,alto+2) ' copia del bolas, con +1 por cada lado, para usar el borde como comprobacion
	suma=0
	salir=0
	
	If mx>ancho Or my>alto Then Return 0 ' si estamos fuera de limites
	
	' bola tocada
	pieza=bolas(mx,my)
	If pieza=0 Then Return 0 ' vacios no se tratan
	
	' copia de matriz con solo las bolas a tratar del color picado
	For x=0 To ancho-1
		For y=0 To alto-1
			If bolas(x,y)=pieza Then bolas2(x+1,y+1)=bolas(x,y)
		Next y
	Next x
	
	' primera comprobacion de piezas alrededor
	x=mx+1
	y=my+1
	
	bolas2(x,y)=-1
	If bolas2(x-1,y  )=pieza Then bolas2(x-1,y  )=-1:suma+=1
	If bolas2(x  ,y-1)=pieza Then bolas2(x  ,y-1)=-1:suma+=1
	If bolas2(x+1,y  )=pieza Then bolas2(x+1,y  )=-1:suma+=1
	If bolas2(x  ,y+1)=pieza Then bolas2(x  ,y+1)=-1:suma+=1
	If suma=0 Then Return 0 ' no hay parejas, esta sola, salimos
	
	' si hemos encontrado una coincidencia, buscamos mas
	While 1
		salir=1
		For x=1 To ancho
			For y=1 To alto
				If bolas2(x,y)=-1 Then
					If bolas2(x-1,y  )=pieza Then bolas2(x-1,y  )=-1:suma+=1:salir=0
					If bolas2(x  ,y-1)=pieza Then bolas2(x  ,y-1)=-1:suma+=1:salir=0
					If bolas2(x+1,y  )=pieza Then bolas2(x+1,y  )=-1:suma+=1:salir=0
					If bolas2(x  ,y+1)=pieza Then bolas2(x  ,y+1)=-1:suma+=1:salir=0
				End If
			Next y
		Next x
		If salir=1 Then exit While
	Wend 
	
	' borro las bolas que coinciden
	ScreenLock
	For x=0 To ancho-1
		For y=0 To alto-1
			If bolas2(x+1,y+1)=-1 Then 
				Put (x*anchobola,y*anchobola), gris1,PSet:Sleep 10
				'Put (x*anchobola,y*anchobola), gris2,PSet:Sleep 2
				'Put (x*anchobola,y*anchobola), gris3,PSet:Sleep 2
				'Put (x*anchobola,y*anchobola), gris4,PSet:Sleep 2
				'Put (x*anchobola,y*anchobola), gris5,PSet:Sleep 2
				'Put (x*anchobola,y*anchobola), gris6,PSet:Sleep 2
				bolas(x,y)=0
			EndIf
		Next y
	Next x
	ScreenUnLock
	
	Sleep 250,1
	
	Return suma+1
End function

' arrejunto huecos
Sub limpia_huecos()
	Dim As Integer x,y,x2,y2

	' primero filas, dejo "caer" las bolas
	For x=0 To ancho-1
		y=alto-1
		While y>0
			x2=0
			If bolas(x,y)=0 Then ' hueco encontrado, arrejunto hacia abajo toda la columna
				For y2=y To 1 Step -1
					bolas(x,y2)=bolas(x,y2-1)
					x2=x2+bolas(x,y2)
					'Circle(x*110+55,y2*110+55),5,RGB(255,255,255),,,,F
				Next y2
				'sleep
				bolas(x,0)=0 ' la primera posicion de arriba se pone a 01
				If x2=0 Then y-=1
			Else 
				y-=1
			EndIf
		Wend
	Next x
	
	
	' ahora columnas, las "pego" a la derecha y añado nueva
	For x=ancho-1 To 0 Step -1' voy de derecha a izquierda
		'Circle(x*110+55,(alto-1)*110+55),5,RGB(255,255,255),,,,F
		If bolas(x,alto-1)=0 Then ' si la bola de abajo del todo esta vacia, junto todo a la derecha
			'Sleep
			For x2=x-1 To 0 Step -1
				For y2=0 To alto-1
					bolas(x2+1,y2)=bolas(x2,y2)
					'Circle((x2+1)*110+55,y2*110+55),5,RGB(255,255,0),,,,F
				Next y2
			Next x2
			' relleno la primera con una nueva aleatoria
			For y2=0 To alto-1
				bolas(0,y2)=Int(Rnd(1)*6)+1
			Next
			' si al acabar, la fila recien rotada a la derecha, tambien esta vacia, repetimos el paso....
			If bolas(x,alto-1)=0 Then x+=1 ' fuerzo al bucle a repetir esta fila, por que esta vacia tambien
		EndIf
	Next x	
	
End Sub

' compruebo si hay mas posibilidades, o si se acaba el juego
function fin_juego() As Integer
	Dim As Integer x,y,x2,y2,pieza
	Dim As Byte bolas2(ancho+2,alto+2) ' copia del bolas, con +1 por cada lado, para usarlo vacio

		For x=0 To ancho-1
			For y=0 To alto-1
				If bolas(x,y)>0 Then bolas2(x+1,y+1)=bolas(x,y)
			Next y
		Next x

		For x=1 To ancho
			For y=1 To alto
				pieza=bolas2(x,y)
				If pieza>0 Then
					If bolas2(x-1,y  )=pieza Then Return 0
					If bolas2(x  ,y-1)=pieza Then Return 0
					If bolas2(x+1,y  )=pieza Then Return 0
					If bolas2(x  ,y+1)=pieza Then Return 0
				End If
			Next y
		Next x
		
		' fin, no hay mas piezas
		Return 1
End Function


' poseso, dibuja
Sub dibuja()
	ScreenLock
	cls
	Dim As Integer x,y,pieza
	For x=0 To ancho-1
		For y=0 To alto-1
			pieza=bolas(x,y)
			If pieza=0 Then Put (x*anchobola,y*anchobola), vacio,PSet
			If pieza=1 Then Put (x*anchobola,y*anchobola), roja ,PSet
			If pieza=2 Then Put (x*anchobola,y*anchobola), verde,PSet
			If pieza=3 Then Put (x*anchobola,y*anchobola), azul ,PSet
			If pieza=4 Then Put (x*anchobola,y*anchobola), amari,PSet
			If pieza=5 Then Put (x*anchobola,y*anchobola), cian ,PSet
			If pieza=6 Then Put (x*anchobola,y*anchobola), morad,PSet
			'If pieza=6 Then Puts ((x*anchobola)/escala),((y*anchobola)/escala), morad,3
		Next y
	Next x


	' separacion abajo
	Line(0,((alto-1)*anchobola)+112)-(((ancho-1)*anchobola)+(anchobola-1),((alto-1)*anchobola)+116),RGB(100,100,100),bf
	'separacion derecha, para el deshacer
	Line(((ancho-1)*anchobola),((alto-1)*anchobola)+112)-(((ancho-1)*anchobola)+4,((alto-1)*anchobola)+164),RGB(100,100,100),bf
	' separacion izquierda, para "nuevo"
	Line(anchobola,((alto-1)*anchobola)+112)-(114,((alto-1)*anchobola)+164),RGB(100,100,100),bf
	
	
	' puntuacion
	Draw String ( ((ancho/2)*anchobola)+20,(alto*anchobola)+20 ),Str(puntos_total)
	
	screenunlock
End Sub


' resolucion temporal para captura de graficos
ScreenRes 1024,768,32
' planto el principal en pantalla para capturarlo
Dim myImage As Any Ptr = ImageCreate( 800, 480 )
BLoad "bolas.bmp", myImage
Put (0,0), myImage
ImageDestroy( myImage )


' cojo bolas de 109x109 (reservo 1 pixel de mas por lado)
vacio = ImageCreate( anchobola, anchobola )
'
gris1 = ImageCreate( anchobola, anchobola )
gris2 = ImageCreate( anchobola, anchobola )
gris3 = ImageCreate( anchobola, anchobola )
gris4 = ImageCreate( anchobola, anchobola )
gris5 = ImageCreate( anchobola, anchobola )
gris6 = ImageCreate( anchobola, anchobola )
'
roja  = ImageCreate( anchobola, anchobola )
verde = ImageCreate( anchobola, anchobola )
azul  = ImageCreate( anchobola, anchobola )
amari = ImageCreate( anchobola, anchobola )
cian  = ImageCreate( anchobola, anchobola )
morad = ImageCreate( anchobola, anchobola )
'
Get (anchobola*0,anchobola*0)-step(anchobola-1,anchobola-1), gris1
Get (anchobola*1,anchobola*0)-step(anchobola-1,anchobola-1), gris2
Get (anchobola*2,anchobola*0)-Step(anchobola-1,anchobola-1), gris3
Get (anchobola*3,anchobola*0)-Step(anchobola-1,anchobola-1), gris4
Get (anchobola*4,anchobola*0)-Step(anchobola-1,anchobola-1), gris5
Get (anchobola*5,anchobola*0)-Step(anchobola-1,anchobola-1), gris6
'
Get (anchobola*0,anchobola*1)-step(anchobola-1,anchobola-1), roja
Get (anchobola*1,anchobola*1)-step(anchobola-1,anchobola-1), verde
Get (anchobola*2,anchobola*1)-Step(anchobola-1,anchobola-1), azul
Get (anchobola*3,anchobola*1)-Step(anchobola-1,anchobola-1), amari
Get (anchobola*4,anchobola*1)-Step(anchobola-1,anchobola-1), cian
Get (anchobola*5,anchobola*1)-Step(anchobola-1,anchobola-1), morad
'Put (0,200),roja,PSet:sleep

Get (anchobola*0,anchobola*2)-step(anchobola-1,anchobola-1), vacio



' resolucion real
ScreenRes 549+10, 870+10,32


' relleno la matriz inicial
For x=0 To ancho-1
	For y=0 To alto-1
		rand=Int(Rnd(1)*6)+1
		bolas(x,y)=rand
		bolas_copia(x,y)=rand
	Next y
Next x

' primer dibujado
dibuja()



While 1
	If mb=1 Then 
		mb=0
	Else
		GetMouse(mx,my,,mb)
	EndIf

	
	mx=mx \ anchobola
	my=my \ anchobola
		
	'Locate 1,1:Print mx,my
			
	If mb=1 Then 
		'Sleep 100,1 ' necesario para evitar autorepeticion de click

		' deshacer
		If mx=ancho-1 And my=alto Then
			For x=0 To ancho-1
				For y=0 To alto-1
					bolas(x,y)=bolas_copia(x,y)
				Next y
			Next x
			If verif>1 Then puntos_total=puntos_total-(2^(verif/2)) ' restamos los puntos 
			dibuja()
			verif=0
			Sleep 250,1
			GoTo salir
		EndIf


		' copia para deshacer, no cambia si la ultima vez no se quitaron bolas
		If verif Then 
			For x=0 To ancho-1
				For y=0 To alto-1
					bolas_copia(x,y)=bolas(x,y)
				Next y
			Next x
		End If
		
		
		' verificacion
		verif=verifica(mx,my) ' si no se quitan bolas, el undo permanece intacto
		' sumamos puntos
		If verif>1 Then puntos_total=puntos_total+(2^(verif/2))		

		' nuevo, si pulsamos abajo a la izquierda
		If mx=0 And my=alto Then
			For x=0 To ancho-1
				For y=0 To alto-1
					rand=Int(Rnd(1)*6)+1
					bolas(x,y)=rand
					bolas_copia(x,y)=rand
				Next y
			Next x
			puntos_total=0
			dibuja()
			Sleep 250,1
			GoTo salir
		EndIf 
	
	
		
		limpia_huecos()
		dibuja()

		
		If fin_juego() Then
			Circle (300,300),200,RGB(200,200,0),,,,F
			Print "PUNTOS:";puntos_total
			Sleep
			End
		EndIf
		
	salir:
	EndIf
	
	If InKey=Chr(27) Then end
Wend


