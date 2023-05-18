
#############################################################################################################################
function isCycle_and_simulUpdate(::Val{1},index::Int,j::Int, x::Vector{Taylor0{Float64}},q::Vector{Taylor0{Float64}}, quantum::Vector{Float64},a::MVector{T,MVector{T,Float64}},u::MVector{T,MVector{T,MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}},tx::MVector{T,Float64},tq::MVector{T,Float64},tu::MVector{T,Float64},simt::Float64,ft::Float64)where{T,O}
  aii=a[index][index];ajj=a[j][j];aij=a[index][j];aji=a[j][index];uij=u[index][j][1];uji=u[j][index][1];xi=x[index][0];xj=x[j][0];x1i=x[index][1];x1j=x[j][1]
  qi=q[index][0];qj=q[j][0]
  quanj=quantum[j];quani=quantum[index]
  qaux[j][1]=qj;olddx[j][1]=x1j
 
  elapsed = simt - tx[j];x[j][0]= xj+elapsed*x1j;xjaux=x[j][0]
  tx[j]=simt
  u[j][index][1]=u[j][j][1]-aji*qaux[index][1]
  uji=u[j][index][1]
  dxj=aji*qi+ajj*qj+uji
  iscycle=false 
  if dxj*x1j<0
    qjplus=xjaux+sign(dxj)*quanj
    u[index][j][1]=u[index][index][1]-aij*qj#qaux[j][1]
    uij=u[index][j][1]
    dxi=aii*qi+aij*qjplus+uij
    if dxi*x1i<0
      iscycle=true  
        
      h = ft-simt
      Δ=(1-h*aii)*(1-h*ajj)-h*h*aij*aji
      qi = ((1-h*ajj)*(xi+h*uij)+h*aij*(xjaux+h*uji))/Δ
      qj = ((1-h*aii)*(xjaux+h*uji)+h*aji*(xi+h*uij))/Δ
      if (abs(qi - xi) > quani || abs(qj - xjaux) > 2*quanj) 
        h1 = (abs(quani / x1i));h2 = (abs(quanj / x1j));
        h=min(h1,h2)
        Δ=(1-h*aii)*(1-h*ajj)-h*h*aij*aji
        if Δ==0
          Δ=1e-12
        end
        qi = ((1-h*ajj)*(xi+h*uij)+h*aij*(xjaux+h*uji))/Δ
        qj = ((1-h*aii)*(xjaux+h*uji)+h*aji*(xi+h*uij))/Δ
      end
      maxIter=1000
      while (abs(qi - xi) > quani || abs(qj - xjaux) > quanj) && (maxIter>0)
        maxIter-=1
        h1 = h * (0.96*quani / abs(qi - xi));
        h2 = h * (0.96*quanj / abs(qj - xjaux));
        h=min(h1,h2)
        Δ=(1-h*aii)*(1-h*ajj)-h*h*aij*aji
        if Δ==0
          Δ=1e-12
          #println("delta liqss1 simulupdate==0")
        end
        qi = ((1-h*ajj)*(xi+h*uij)+h*aij*(xjaux+h*uji))/Δ
        qj = ((1-h*aii)*(xjaux+h*uji)+h*aji*(xi+h*uij))/Δ
        if maxIter < 1
          println("maxiter of updateQ      = ",maxIter)
         end
        end

      q[index][0]=qi# store back helper vars
      q[j][0]=qj
      tq[j]=simt

    end #end second dependecy check
 end # end outer dependency check
 return iscycle
end
 #this for old mliqss        
function isCycle_and_simulUpdate(::Val{2},index::Int,j::Int,prevStepVal::MVector{T,MVector{B,Float64}},#= direction::MVector{T,Float64}, =# x::Vector{Taylor0{Float64}},q::Vector{Taylor0{Float64}}, quantum::Vector{Float64},a::Vector{Vector{Float64}},u::Vector{Vector{MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}}#= ,olddxSpec::MVector{T,MVector{O,Float64}} =#,tx::MVector{T,Float64},tq::MVector{T,Float64},tu::MVector{T,Float64},simt::Float64,ft::Float64#= ,qminus::MVector{T,Float64} =##= ,breakloop::MVector{1,Float64}, =##= nextStateTime::MVector{T,Float64} =#)where{T,O,B}
  aii=a[index][index];ajj=a[j][j];aij=a[index][j];aji=a[j][index];xi=x[index][0];xj=x[j][0];qi=q[index][0];qj=q[j][0];qi1=q[index][1];qj1=q[j][1];xi1=x[index][1];xi2=2*x[index][2];xj1=x[j][1];xj2=2*x[j][2]
  uii=u[index][index][1];ujj=u[j][j][1]#;uij=u[index][j][1];uji=u[j][index][1]#;uji2=u[j][index][2]
  quanj=quantum[j];quani=quantum[index]; 
  e1 = simt - tx[j];e2 = simt - tq[j];e3=simt - tu[j];tu[j]=simt; 
  x[j][0]= x[j](e1);xjaux=x[j][0];tx[j]=simt
   qj=qj+e2*qj1  ;qaux[j][1]=qj;tq[j] = simt    ;q[j][0]=qj  
  xj1=x[j][1]+e1*xj2#= ;olddxSpec[j][1]=xj1 =#;olddx[j][1]=xj1
  ujj=ujj+e1*u[j][j][2]  
 #ujj=xj1-ajj*qj
  u[j][j][1]=ujj
  u[j][index][1]=ujj-aji*qaux[index][1]# using q[i][0] creates a really huge bump at 18 (no go) because we want to elaps-update uji
  uji=u[j][index][1]
  #u[j][j][2]=xj2-ajj*qj1###################################################-----------------------
  u[j][index][2]=u[j][j][2]-aji*qaux[index][2]#less cycles but with a bump at 1.5...ft20: smooth with some bumps
 #u[j][index][2]=u[j][j][2]-ajj*qaux[index][1] # from article p20 line25 more cycles ...shaky with no bumps
  uji2=u[j][index][2] 

  dxj=aji*qi+ajj*qaux[j][1]+uji
  ddxj=aji*qi1+ajj*qj1+uji2

  iscycle=false
  if (abs(dxj-xj1)>(abs(dxj+xj1)/2) || abs(ddxj-xj2)>(abs(ddxj+xj2)/2))
    qjplus=xjaux-sign(ddxj)*quanj
    h=sqrt(2*quanj/abs(ddxj))#2*quantum funny oscillating graph; xj2 vibrating
    dqjplus=(aji*(qi+h*qi1)+ajj*qjplus+uji+h*uji2)/(1-h*ajj)
    u[index][j][1]=uii-aij*qaux[j][1]
    uij=u[index][j][1]
    u[index][j][2]=u[index][index][2]-aij*qj1#########qaux[j][2] updated in normal Qupdate..ft=20 slightly shifts up
    uij2=u[index][j][2]
    dxi=aii*qi+aij*qjplus+uij
    ddxi=aii*qi1+aij*dqjplus+uij2
  if (abs(dxi-xi1)>(abs(dxi+xi1)/2) || abs(ddxi-xi2)>(abs(ddxi+xi2)/2))

        iscycle=true

            h = ft-simt

        Δ1=(1-h*aii)*(1-h*ajj)-h*h*aij*aji
        αii=(aii*(1-h*ajj)+h*aij*aji)/Δ1
       αij=((1-h*ajj)*aij+h*aij*ajj)/Δ1
       αji=(aji*aii*h+(1-h*aii)*aji)/Δ1
       αjj=(h*aji*aij+(1-h*aii)*ajj)/Δ1
       βii=1+h*(αii-aii)-h*h*(aii*αii+aij*αji)/2
       βij=h*(αij-aij)-h*h*(aii*αij+aij*αjj)/2
       βji=h*(αji-aji)-h*h*(aji*αii+ajj*αji)/2
       βjj=1+h*(αjj-ajj)-h*h*(aji*αij+ajj*αjj)/2

       Δ2=βii*βjj-βij*βji

        λii=(h*h*aii/2-h)*(1-h*ajj)+h*h*h*aji*aij/2
        λij=(h*h*aii/2-h)*h*aij+h*h*aij*(1-h*aii)/2
        λji=h*h*aji/2*(1-h*ajj)+(h*h*ajj/2-h)*h*aji
        λjj=h*h*h*aij*aji/2+(h*h*ajj/2-h)*(1-h*aii)

        parti=((λii*(uij+h*uij2)+λij*(uji+h*uji2))/Δ1)+(xi+h*uij+h*h*uij2/2)#part1[1]+xpart2[1]#
        partj=((λji*(uij+h*uij2)+λjj*(uji+h*uji2))/Δ1)+(xjaux+h*uji+h*h*uji2/2)#part1[2]+xpart2[2]#

        qi=((βjj/Δ2)*parti-(βij/Δ2)*partj)
         qj=((βii/Δ2)*partj-(βji/Δ2)*parti)

        if (abs(qi - xi) > quani || abs(qj - xjaux) > quanj) 
          h1 = sqrt(abs(2*quani/xi2));h2 = sqrt(abs(2*quanj/xj2));   #later add derderX =1e-12 when x2==0
          h=min(h1,h2)

          Δ1=(1-h*aii)*(1-h*ajj)-h*h*aij*aji

        αii=(aii*(1-h*ajj)+h*aij*aji)/Δ1
        αij=((1-h*ajj)*aij+h*aij*ajj)/Δ1
        αji=(aji*aii*h+(1-h*aii)*aji)/Δ1
        αjj=(h*aji*aij+(1-h*aii)*ajj)/Δ1

        βii=1+h*(αii-aii)-h*h*(aii*αii+aij*αji)/2
        βij=h*(αij-aij)-h*h*(aii*αij+aij*αjj)/2
        βji=h*(αji-aji)-h*h*(aji*αii+ajj*αji)/2
        βjj=1+h*(αjj-ajj)-h*h*(aji*αij+ajj*αjj)/2

         Δ2=βii*βjj-βij*βji
 
        λii=(h*h*aii/2-h)*(1-h*ajj)+h*h*h*aji*aij/2
        λij=(h*h*aii/2-h)*h*aij+h*h*aij*(1-h*aii)/2
        λji=h*h*aji/2*(1-h*ajj)+(h*h*ajj/2-h)*h*aji
        λjj=h*h*h*aij*aji/2+(h*h*ajj/2-h)*(1-h*aii)

        parti=((λii*(uij+h*uij2)+λij*(uji+h*uji2))/Δ1)+(xi+h*uij+h*h*uij2/2)#part1[1]+xpart2[1]#
        partj=((λji*(uij+h*uij2)+λjj*(uji+h*uji2))/Δ1)+(xjaux+h*uji+h*h*uji2/2)#part1[2]+xpart2[2]#
  
        
         qi=((βjj/Δ2)*parti-(βij/Δ2)*partj)
         qj=((βii/Δ2)*partj-(βji/Δ2)*parti)
  
        end
       
        maxIter=600
        while (abs(qi - xi) > quani || abs(qj - xjaux) > quanj) && (maxIter>0)
          maxIter-=1
          h1 = h * (0.98*quani / abs(qi - xi));
          h2 = h * (0.98*quanj / abs(qj - xjaux));
          h=min(h1,h2)

          Δ1=(1-h*aii)*(1-h*ajj)-h*h*aij*aji

          αii=(aii*(1-h*ajj)+h*aij*aji)/Δ1
          αij=((1-h*ajj)*aij+h*aij*ajj)/Δ1
          αji=(aji*aii*h+(1-h*aii)*aji)/Δ1
          αjj=(h*aji*aij+(1-h*aii)*ajj)/Δ1

          βii=1+h*(αii-aii)-h*h*(aii*αii+aij*αji)/2
          βij=h*(αij-aij)-h*h*(aii*αij+aij*αjj)/2
          βji=h*(αji-aji)-h*h*(aji*αii+ajj*αji)/2
          βjj=1+h*(αjj-ajj)-h*h*(aji*αij+ajj*αjj)/2
 
           Δ2=βii*βjj-βij*βji
  


        λii=(h*h*aii/2-h)*(1-h*ajj)+h*h*h*aji*aij/2
        λij=(h*h*aii/2-h)*h*aij+h*h*aij*(1-h*aii)/2
        λji=h*h*aji/2*(1-h*ajj)+(h*h*ajj/2-h)*h*aji
        λjj=h*h*h*aij*aji/2+(h*h*ajj/2-h)*(1-h*aii)

        parti=((λii*(uij+h*uij2)+λij*(uji+h*uji2))/Δ1)+(xi+h*uij+h*h*uij2/2)#part1[1]+xpart2[1]#
        partj=((λji*(uij+h*uij2)+λjj*(uji+h*uji2))/Δ1)+(xjaux+h*uji+h*h*uji2/2)#part1[2]+xpart2[2]#
      
        qi=((βjj/Δ2)*parti-(βij/Δ2)*partj)
         qj=((βii/Δ2)*partj-(βji/Δ2)*parti)


       
          
        end
    
        if maxIter < 1
           @show maxIter
           @show simt
           @show a
        end


     
        q[index][0]=qi# store back helper vars
        q[j][0]=qj
      
         q1parti=aii*qi+aij*qj+uij+h*uij2
         q1partj=aji*qi+ajj*qj+uji+h*uji2
      
         q[index][1]=((1-h*ajj)/Δ1)*q1parti+(h*aij/Δ1)*q1partj# store back helper vars
        q[j][1]=(h*aji/Δ1)*q1parti+((1-h*aii)/Δ1)*q1partj
           
          
      
      end #end second dependecy check
    end # end outer dependency check
  return iscycle
end
function nisCycle_and_simulUpdate(::Val{2},index::Int,j::Int,prevStepVal::MVector{T,MVector{B,Float64}},direction::MVector{T,Float64}, x::Vector{Taylor0{Float64}},q::Vector{Taylor0{Float64}}, quantum::Vector{Float64},a::Vector{Vector{Float64}},u::Vector{Vector{MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}},olddxSpec::MVector{T,MVector{O,Float64}},tx::MVector{T,Float64},tq::MVector{T,Float64},tu::MVector{T,Float64},simt::Float64,ft::Float64,qminus::MVector{T,Float64}#= ,breakloop::MVector{1,Float64}, =##= nextStateTime::MVector{T,Float64} =#)where{T,O,B}
  aii=a[index][index];ajj=a[j][j];aij=a[index][j];aji=a[j][index];xi=x[index][0];xj=x[j][0];qi=q[index][0];qj=q[j][0];qi1=q[index][1];qj1=q[j][1];xi1=x[index][1];xi2=2*x[index][2];xj1=x[j][1];xj2=2*x[j][2]
  uii=u[index][index][1];ujj=u[j][j][1]#;uij=u[index][j][1];uji=u[j][index][1]#;uji2=u[j][index][2]
  quanj=quantum[j];quani=quantum[index];
    
  e1 = simt - tx[j];e2 = simt - tq[j];e3=simt - tu[j];tu[j]=simt; 
  x[j][0]= x[j](e1);xjaux=x[j][0];tx[j]=simt
  qminus[j]=qj
  qj=qj+e2*qj1  ;qaux[j][1]=qj;tq[j] = simt    ;q[j][0]=qj  

 

  xj1=x[j][1]+e1*xj2;olddxSpec[j][1]=xj1;olddx[j][1]=xj1
 
  

  #ujj=ujj+e1*u[j][j][2]  
  ujj=xj1-ajj*qj
  u[j][j][1]=ujj
  u[j][index][1]=ujj-aji*qaux[index][1]# using q[i][0] creates a really huge bump at 18 (no go) because we want to elaps-update uji
  uji=u[j][index][1]

  u[j][j][2]=xj2-ajj*qj1###################################################-----------------------

  u[j][index][2]=u[j][j][2]-aji*qaux[index][2]#
 
  uji2=u[j][index][2] 


  #@show uji2
  dxj=aji*qi+ajj*qaux[j][1]+uji
  ddxj=aji*qi1+ajj*qj1+uji2
  #@show aji,ajj,uji2
  iscycle=false
  
    u[index][j][1]=uii-aij*qaux[j][1]
    uij=u[index][j][1]
    u[index][j][2]=u[index][index][2]-aij*qj1#########qaux[j][2] updated in normal Qupdate..ft=20 slightly shifts up
    uij2=u[index][j][2]

    qjplus=xjaux-sign(ddxj)*quanj
    h=sqrt(2*quanj/abs(ddxj))#2*quantum funny oscillating graph; xj2 vibrating
    dqjplus=(aji*(qi+h*qi1)+ajj*qjplus+uji+h*uji2)/(1-h*ajj)
   
    dxi=aii*qi+aij*qjplus+uij
    ddxi=aii*qi1+aij*dqjplus+uij2
  
  
    if (abs(dxj-xj1)>(abs(dxj+xj1)/2) || abs(ddxj-xj2)>(abs(ddxj+xj2)/2))  #|| (dqjplus)*dirj<0.0 #(dqjplus*qj1)<=0.0 with dir is better since when dir =0 we do not enter
      #β=dxi+sqrt(abs(ddxi)*quani/2)
      h22=sqrt(2*quani/abs(ddxi))
      β=dxi+h22*ddxi/2
      if (abs(dxi-xi1)>(abs(dxi+xi1)/2) || abs(ddxi-xi2)>(abs(ddxi+xi2)/2)) #|| β*direction[index]<0.0

   
        iscycle=true
      

        h = ft-simt

        Δ1=(1-h*aii)*(1-h*ajj)-h*h*aij*aji
        αii=(aii*(1-h*ajj)+h*aij*aji)/Δ1
       αij=((1-h*ajj)*aij+h*aij*ajj)/Δ1
       αji=(aji*aii*h+(1-h*aii)*aji)/Δ1
       αjj=(h*aji*aij+(1-h*aii)*ajj)/Δ1
       βii=1+h*(αii-aii)-h*h*(aii*αii+aij*αji)/2
       βij=h*(αij-aij)-h*h*(aii*αij+aij*αjj)/2
       βji=h*(αji-aji)-h*h*(aji*αii+ajj*αji)/2
       βjj=1+h*(αjj-ajj)-h*h*(aji*αij+ajj*αjj)/2

       Δ2=βii*βjj-βij*βji

        λii=(h*h*aii/2-h)*(1-h*ajj)+h*h*h*aji*aij/2
        λij=(h*h*aii/2-h)*h*aij+h*h*aij*(1-h*aii)/2
        λji=h*h*aji/2*(1-h*ajj)+(h*h*ajj/2-h)*h*aji
        λjj=h*h*h*aij*aji/2+(h*h*ajj/2-h)*(1-h*aii)

        parti=((λii*(uij+h*uij2)+λij*(uji+h*uji2))/Δ1)+(xi+h*uij+h*h*uij2/2)#part1[1]+xpart2[1]#
        partj=((λji*(uij+h*uij2)+λjj*(uji+h*uji2))/Δ1)+(xjaux+h*uji+h*h*uji2/2)#part1[2]+xpart2[2]#

        qi=((βjj/Δ2)*parti-(βij/Δ2)*partj)
         qj=((βii/Δ2)*partj-(βji/Δ2)*parti)

        if (abs(qi - xi) > quani || abs(qj - xjaux) > quanj) 
          h1 = sqrt(abs(2*quani/xi2));h2 = sqrt(abs(2*quanj/xj2));   #later add derderX =1e-12 when x2==0
          h=min(h1,h2)

          Δ1=(1-h*aii)*(1-h*ajj)-h*h*aij*aji

        αii=(aii*(1-h*ajj)+h*aij*aji)/Δ1
        αij=((1-h*ajj)*aij+h*aij*ajj)/Δ1
        αji=(aji*aii*h+(1-h*aii)*aji)/Δ1
        αjj=(h*aji*aij+(1-h*aii)*ajj)/Δ1

        βii=1+h*(αii-aii)-h*h*(aii*αii+aij*αji)/2
        βij=h*(αij-aij)-h*h*(aii*αij+aij*αjj)/2
        βji=h*(αji-aji)-h*h*(aji*αii+ajj*αji)/2
        βjj=1+h*(αjj-ajj)-h*h*(aji*αij+ajj*αjj)/2

         Δ2=βii*βjj-βij*βji
 
        λii=(h*h*aii/2-h)*(1-h*ajj)+h*h*h*aji*aij/2
        λij=(h*h*aii/2-h)*h*aij+h*h*aij*(1-h*aii)/2
        λji=h*h*aji/2*(1-h*ajj)+(h*h*ajj/2-h)*h*aji
        λjj=h*h*h*aij*aji/2+(h*h*ajj/2-h)*(1-h*aii)

        parti=((λii*(uij+h*uij2)+λij*(uji+h*uji2))/Δ1)+(xi+h*uij+h*h*uij2/2)#part1[1]+xpart2[1]#
        partj=((λji*(uij+h*uij2)+λjj*(uji+h*uji2))/Δ1)+(xjaux+h*uji+h*h*uji2/2)#part1[2]+xpart2[2]#
  
        
         qi=((βjj/Δ2)*parti-(βij/Δ2)*partj)
         qj=((βii/Δ2)*partj-(βji/Δ2)*parti)
  
        end
       
        maxIter=600
        while (abs(qi - xi) > quani || abs(qj - xjaux) > quanj) && (maxIter>0)
          maxIter-=1
          h1 = h * (0.98*quani / abs(qi - xi));
          h2 = h * (0.98*quanj / abs(qj - xjaux));
          h=min(h1,h2)

          Δ1=(1-h*aii)*(1-h*ajj)-h*h*aij*aji

          αii=(aii*(1-h*ajj)+h*aij*aji)/Δ1
          αij=((1-h*ajj)*aij+h*aij*ajj)/Δ1
          αji=(aji*aii*h+(1-h*aii)*aji)/Δ1
          αjj=(h*aji*aij+(1-h*aii)*ajj)/Δ1

          βii=1+h*(αii-aii)-h*h*(aii*αii+aij*αji)/2
          βij=h*(αij-aij)-h*h*(aii*αij+aij*αjj)/2
          βji=h*(αji-aji)-h*h*(aji*αii+ajj*αji)/2
          βjj=1+h*(αjj-ajj)-h*h*(aji*αij+ajj*αjj)/2
 
           Δ2=βii*βjj-βij*βji
  


        λii=(h*h*aii/2-h)*(1-h*ajj)+h*h*h*aji*aij/2
        λij=(h*h*aii/2-h)*h*aij+h*h*aij*(1-h*aii)/2
        λji=h*h*aji/2*(1-h*ajj)+(h*h*ajj/2-h)*h*aji
        λjj=h*h*h*aij*aji/2+(h*h*ajj/2-h)*(1-h*aii)

        parti=((λii*(uij+h*uij2)+λij*(uji+h*uji2))/Δ1)+(xi+h*uij+h*h*uij2/2)#part1[1]+xpart2[1]#
        partj=((λji*(uij+h*uij2)+λjj*(uji+h*uji2))/Δ1)+(xjaux+h*uji+h*h*uji2/2)#part1[2]+xpart2[2]#
      
        qi=((βjj/Δ2)*parti-(βij/Δ2)*partj)
         qj=((βii/Δ2)*partj-(βji/Δ2)*parti)


       
          
        end
    
        if maxIter < 1
           @show maxIter
           @show simt
           @show a
        end


     
        q[index][0]=qi# store back helper vars
        q[j][0]=qj
      
         q1parti=aii*qi+aij*qj+uij+h*uij2
         q1partj=aji*qi+ajj*qj+uji+h*uji2
      
         q[index][1]=((1-h*ajj)/Δ1)*q1parti+(h*aij/Δ1)*q1partj# store back helper vars
        q[j][1]=(h*aji/Δ1)*q1parti+((1-h*aii)/Δ1)*q1partj
      
           
      
       # end#if changexj>changexi
      end #end second dependecy check
    end # end outer dependency check
  return iscycle
end
function nmisCycle_and_simulUpdate(::Val{2},index::Int,j::Int,prevStepVal::MVector{T,MVector{B,Float64}},direction::MVector{T,Float64}, x::Vector{Taylor0{Float64}},q::Vector{Taylor0{Float64}}, quantum::Vector{Float64},a::Vector{Vector{Float64}},u::Vector{Vector{MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}},olddxSpec::MVector{T,MVector{O,Float64}},tx::MVector{T,Float64},tq::MVector{T,Float64},tu::MVector{T,Float64},simt::Float64,ft::Float64,qminus::MVector{T,Float64}#= ,breakloop::MVector{1,Float64}, =##= nextStateTime::MVector{T,Float64} =#)where{T,O,B}
  
  
  
  aii=a[index][index];ajj=a[j][j];aij=a[index][j];aji=a[j][index];xi=x[index][0];xj=x[j][0];qi=q[index][0];qj=q[j][0];qi1=q[index][1];qj1=q[j][1];xi1=x[index][1];xi2=2*x[index][2];xj1=x[j][1];xj2=2*x[j][2]
  uii=u[index][index][1];ujj=u[j][j][1]#;uij=u[index][j][1];uji=u[j][index][1]#;uji2=u[j][index][2]
  quanj=quantum[j];quani=quantum[index];
    
  e1 = simt - tx[j];e2 = simt - tq[j];e3=simt - tu[j];tu[j]=simt; 
  x[j][0]= x[j](e1);xjaux=x[j][0];tx[j]=simt
  qminus[j]=qj
  qj=qj+e2*qj1  ;qaux[j][1]=qj;tq[j] = simt    ;q[j][0]=qj  

  newDiff=(xjaux-prevStepVal[j][1])
  dirj=direction[j]
  if newDiff*dirj <0.0
    dirj=-dirj
 
  elseif newDiff==0 && dirj!=0.0
    dirj=0.0
   
  elseif newDiff!=0 && dirj==0.0
    dirj=newDiff
  else
 
  end          
  direction[j]=dirj

  xj1=x[j][1]+e1*xj2;olddxSpec[j][1]=xj1;olddx[j][1]=xj1

  

  #ujj=ujj+e1*u[j][j][2]  
  ujj=xj1-ajj*qj
  u[j][j][1]=ujj
  u[j][index][1]=ujj-aji*qaux[index][1]# 
  uji=u[j][index][1]

  u[j][j][2]=xj2-ajj*qj1###################################################-----------------------

  u[j][index][2]=u[j][j][2]-aji*qaux[index][2]#
 #u[j][index][2]=u[j][j][2]-ajj*qaux[index][1] # from article p20 line25 more cycles ...shaky with no bumps
  uji2=u[j][index][2] 


  #@show uji2
  dxj=aji*qi+ajj*qaux[j][1]+uji
  ddxj=aji*qi1+ajj*qj1+uji2
  #@show aji,ajj,uji2
  iscycle=false
  
    u[index][j][1]=uii-aij*qaux[j][1]
    uij=u[index][j][1]
    u[index][j][2]=u[index][index][2]-aij*qj1#########qaux[j][2] updated in normal Qupdate..ft=20 slightly shifts up
    uij2=u[index][j][2]

    qjplus=xjaux-sign(ddxj)*quanj
    h=sqrt(2*quanj/abs(ddxj))#2*quantum funny oscillating graph; xj2 vibrating
    dqjplus=(aji*(qi+h*qi1)+ajj*qjplus+uji+h*uji2)/(1-h*ajj)
   
    dxi=aii*qi+aij*qjplus+uij
    ddxi=aii*qi1+aij*dqjplus+uij2
  

    if (abs(dxj-xj1)>(abs(dxj+xj1)/2) || abs(ddxj-xj2)>(abs(ddxj+xj2)/2))  || (dqjplus)*dirj<0.0 #(dqjplus*qj1)<=0.0 with dir is better since when dir =0 we do not enter
      #β=dxi+sqrt(abs(ddxi)*quani/2)
      #h2=sqrt(2*quani/abs(ddxi))
      βidir=dxi+sqrt(2*quani/abs(ddxi))*ddxi/2
      if (abs(dxi-xi1)>(abs(dxi+xi1)/2) || abs(ddxi-xi2)>(abs(ddxi+xi2)/2)) || βidir*direction[index]<0.0

    
   
        iscycle=true
        h = ft-simt

        Δ1=(1-h*aii)*(1-h*ajj)-h*h*aij*aji
        αii=(aii*(1-h*ajj)+h*aij*aji)/Δ1
       αij=((1-h*ajj)*aij+h*aij*ajj)/Δ1
       αji=(aji*aii*h+(1-h*aii)*aji)/Δ1
       αjj=(h*aji*aij+(1-h*aii)*ajj)/Δ1
       βii=1+h*(αii-aii)-h*h*(aii*αii+aij*αji)/2
       βij=h*(αij-aij)-h*h*(aii*αij+aij*αjj)/2
       βji=h*(αji-aji)-h*h*(aji*αii+ajj*αji)/2
       βjj=1+h*(αjj-ajj)-h*h*(aji*αij+ajj*αjj)/2

       Δ2=βii*βjj-βij*βji

        λii=(h*h*aii/2-h)*(1-h*ajj)+h*h*h*aji*aij/2
        λij=(h*h*aii/2-h)*h*aij+h*h*aij*(1-h*aii)/2
        λji=h*h*aji/2*(1-h*ajj)+(h*h*ajj/2-h)*h*aji
        λjj=h*h*h*aij*aji/2+(h*h*ajj/2-h)*(1-h*aii)

        parti=((λii*(uij+h*uij2)+λij*(uji+h*uji2))/Δ1)+(xi+h*uij+h*h*uij2/2)#part1[1]+xpart2[1]#
        partj=((λji*(uij+h*uij2)+λjj*(uji+h*uji2))/Δ1)+(xjaux+h*uji+h*h*uji2/2)#part1[2]+xpart2[2]#

        qi=((βjj/Δ2)*parti-(βij/Δ2)*partj)
         qj=((βii/Δ2)*partj-(βji/Δ2)*parti)

        if (abs(qi - xi) > quani || abs(qj - xjaux) > quanj) 
          h1 = sqrt(abs(2*quani/xi2));h2 = sqrt(abs(2*quanj/xj2));   #later add derderX =1e-12 when x2==0
          h=min(h1,h2)

          Δ1=(1-h*aii)*(1-h*ajj)-h*h*aij*aji

        αii=(aii*(1-h*ajj)+h*aij*aji)/Δ1
        αij=((1-h*ajj)*aij+h*aij*ajj)/Δ1
        αji=(aji*aii*h+(1-h*aii)*aji)/Δ1
        αjj=(h*aji*aij+(1-h*aii)*ajj)/Δ1

        βii=1+h*(αii-aii)-h*h*(aii*αii+aij*αji)/2
        βij=h*(αij-aij)-h*h*(aii*αij+aij*αjj)/2
        βji=h*(αji-aji)-h*h*(aji*αii+ajj*αji)/2
        βjj=1+h*(αjj-ajj)-h*h*(aji*αij+ajj*αjj)/2

         Δ2=βii*βjj-βij*βji
 
        λii=(h*h*aii/2-h)*(1-h*ajj)+h*h*h*aji*aij/2
        λij=(h*h*aii/2-h)*h*aij+h*h*aij*(1-h*aii)/2
        λji=h*h*aji/2*(1-h*ajj)+(h*h*ajj/2-h)*h*aji
        λjj=h*h*h*aij*aji/2+(h*h*ajj/2-h)*(1-h*aii)

        parti=((λii*(uij+h*uij2)+λij*(uji+h*uji2))/Δ1)+(xi+h*uij+h*h*uij2/2)#part1[1]+xpart2[1]#
        partj=((λji*(uij+h*uij2)+λjj*(uji+h*uji2))/Δ1)+(xjaux+h*uji+h*h*uji2/2)#part1[2]+xpart2[2]#
  
        
         qi=((βjj/Δ2)*parti-(βij/Δ2)*partj)
         qj=((βii/Δ2)*partj-(βji/Δ2)*parti)
  
        end
       
        maxIter=600
        while (abs(qi - xi) > quani || abs(qj - xjaux) > quanj) && (maxIter>0)
          maxIter-=1
          h1 = h * (0.98*quani / abs(qi - xi));
          h2 = h * (0.98*quanj / abs(qj - xjaux));
          h=min(h1,h2)

          Δ1=(1-h*aii)*(1-h*ajj)-h*h*aij*aji

          αii=(aii*(1-h*ajj)+h*aij*aji)/Δ1
          αij=((1-h*ajj)*aij+h*aij*ajj)/Δ1
          αji=(aji*aii*h+(1-h*aii)*aji)/Δ1
          αjj=(h*aji*aij+(1-h*aii)*ajj)/Δ1

          βii=1+h*(αii-aii)-h*h*(aii*αii+aij*αji)/2
          βij=h*(αij-aij)-h*h*(aii*αij+aij*αjj)/2
          βji=h*(αji-aji)-h*h*(aji*αii+ajj*αji)/2
          βjj=1+h*(αjj-ajj)-h*h*(aji*αij+ajj*αjj)/2
 
           Δ2=βii*βjj-βij*βji
  


        λii=(h*h*aii/2-h)*(1-h*ajj)+h*h*h*aji*aij/2
        λij=(h*h*aii/2-h)*h*aij+h*h*aij*(1-h*aii)/2
        λji=h*h*aji/2*(1-h*ajj)+(h*h*ajj/2-h)*h*aji
        λjj=h*h*h*aij*aji/2+(h*h*ajj/2-h)*(1-h*aii)

        parti=((λii*(uij+h*uij2)+λij*(uji+h*uji2))/Δ1)+(xi+h*uij+h*h*uij2/2)#part1[1]+xpart2[1]#
        partj=((λji*(uij+h*uij2)+λjj*(uji+h*uji2))/Δ1)+(xjaux+h*uji+h*h*uji2/2)#part1[2]+xpart2[2]#
      
        qi=((βjj/Δ2)*parti-(βij/Δ2)*partj)
         qj=((βii/Δ2)*partj-(βji/Δ2)*parti)


       
          
        end
    
        if maxIter < 1
           @show maxIter
           @show simt
           @show a
        end


     
        q[index][0]=qi# store back helper vars
        q[j][0]=qj
      
         q1parti=aii*qi+aij*qj+uij+h*uij2
         q1partj=aji*qi+ajj*qj+uji+h*uji2
      
         q[index][1]=((1-h*ajj)/Δ1)*q1parti+(h*aij/Δ1)*q1partj# store back helper vars
        q[j][1]=(h*aji/Δ1)*q1parti+((1-h*aii)/Δ1)*q1partj
     
      end #end second dependecy check
    end # end outer dependency check
  return iscycle
end

function isCycle_and_simulUpdate(::Val{3},index::Int,j::Int,prevStepVal::MVector{T,MVector{B,Float64}},direction::MVector{T,Float64}, x::Vector{Taylor0{Float64}},q::Vector{Taylor0{Float64}}, quantum::Vector{Float64},a::Vector{Vector{Float64}},u::Vector{Vector{MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}},olddxSpec::MVector{T,MVector{O,Float64}},tx::MVector{T,Float64},tq::MVector{T,Float64},tu::MVector{T,Float64},simt::Float64,ft::Float64#= ,flag::MVector{T,Float64} =#)::bool where{T,O,B}
  aii=a[index][index];ajj=a[j][j];aij=a[index][j];aji=a[j][index];xi=x[index][0];xj=x[j][0];qi=q[index][0];qj=q[j][0];qi1=q[index][1];qi2=2*q[index][2];qj1=q[j][1];qj2=2*q[j][2]
  uii=u[index][index][1];uij=u[index][j][1];ujj=u[j][j][1]#;uji=u[j][index][1]#;uji2=u[j][index][2]
  quanj=quantum[j];quani=quantum[index];xi1=x[index][1];xi2=2*x[index][2];xi3=6*x[index][3];xj1=x[j][1];xj2=2*x[j][2];xj3=6*x[j][3]
  e1 = simt - tx[j];e2 = simt - tq[j];e3=simt - tu[j]; tx[j]=simt;tu[j]=simt
  x[j][0]= x[j](e1);xjaux=x[j][0]

  xj1=xj1+e1*xj2+e1*e1*xj3/2;olddxSpec[j][1]=xj1;olddx[j][1]=xj1; xj2=xj2+e1*xj3
  qj=qj+e2*qj1+e2*e2*qj2/2  ;qj1=qj1+e2*qj2; qaux[j][1]=qj ;qaux[j][2]=qj1

  newDiff=(x[j][0]-prevStepVal[j][1])
  dir=direction[j]
  if newDiff*dir <0.0
    direction[j]=-dir

  elseif newDiff==0 && dir!=0.0
    direction[j]=0.0

  elseif newDiff!=0 && dir==0.0
    direction[j]=newDiff
  else
  #do not update direction
  end          




  ujj=ujj+e1*u[j][j][2]+e1*e1*u[j][j][3]/2  
  #ujj=xj1-ajj*qj
  u[j][j][1]=ujj
  #u[j][j][2]=u[j][j][2]+e1*u[j][j][3]
  u[j][j][2]=xj2-ajj*qj1
  u[j][j][3]=xj3-ajj*qj2###################################
  u[j][index][1]=ujj-aji*qaux[index][1]# 
  uji=u[j][index][1]
  u[j][index][2]=u[j][j][2]-aji*qaux[index][2]#less cycles but with a bump at 1.5...ft20: smooth with some bumps
  uji2=u[j][index][2]
   u[j][index][3]=u[j][j][3]-aji*qaux[index][3]#
   uji3=u[j][index][3]

  dxj=aji*qi+ajj*qaux[j][1]+uji
  ddxj=aji*qi1+ajj*qj1+uji2
  dddxj=aji*qi2+ajj*qj2+uji3
 
  iscycle=false

    u[index][j][1]=u[index][index][1]-aij*qaux[j][1]
    uij=u[index][j][1]
    u[index][j][2]=u[index][index][2]-aij*qj1
    uij2=u[index][j][2]
    u[index][j][3]=u[index][index][3]-aij*qj2
    uij3=u[index][j][3]



 # if (abs(dxj-xj1)>(abs(dxj+xj1)/2) || abs(ddxj-xj2)>(abs(ddxj+xj2)/2) || abs(dddxj-xj3)>(abs(dddxj+xj3)/2))  
    




    h1=cbrt(abs(6*quanj/dddxj))
    qjplus=xjaux+h1*h1*h1*dddxj/6
    #@show h,qjplus,xjaux
    λ=ajj*qjplus+aji*qi+uji+h1*(aji*qi1+uji2)+h1*h1*(aji*qi2+uji3)/2
    α=(h1-h1*h1/2)*(aji*(qi1+h1*qi2)+uji2+h1*uji3)/(1-h1*ajj)
    β=1-h1*ajj+(h1-h1*h1/2)*ajj/(1-h1*ajj)
    dqjplus=(λ-α)/β
    ddqjplus=(aji*(qi1+h1*qi2)+ajj*dqjplus+uji2+h1*uji3)/(1-h1*ajj)
   ### 
    #u[index][j][1]=u[index][index][1]-a[index][j]*q[j][0]  # shifts down at 18
   
   #=  u[index][j][1]=u[index][index][1]-aij*qaux[j][1]
    uij=u[index][j][1]
    u[index][j][2]=u[index][index][2]-aij*qj1#########qaux[j][2] updated in normal Qupdate..ft=20 slightly shifts up
    uij2=u[index][j][2] =#
    dxi=aii*qi+aij*qjplus+uij
    ddxi=aii*qi1+aij*dqjplus+uij2
    dddxi=aii*qi2+aij*ddqjplus+uij3
  
 #=  #dqjplus-qj1 is enough: normally (qjplus+h*dqjlpus-qj+h*qj1) . dqjplus-qj1 is better than dqjplus alone cuz the case dqjplus=0
  if (abs(dxj-xj1)>(abs(dxj+xj1)/2) || abs(ddxj-xj2)>(abs(ddxj+xj2)/2))  || (dqjplus+h1*ddqjplus)*direction[j]<0.0 #(dqjplus*qj1)<=0.0 with dir is better since when dir =0 we do not enter
    h2=cbrt(abs(6*quani/dddxi))
    β=dxi+ddxi*h2/2+dddxi*h2*h2/6
    if (abs(dxi-xi1)>(abs(dxi+xi1)/2) || abs(ddxi-xi2)>(abs(ddxi+xi2)/2)) || β*direction[index]<0.0 =#

      if (abs(dxj-xj1)>(abs(dxj+xj1)/2) || abs(ddxj-xj2)>(abs(ddxj+xj2)/2) || abs(dddxj-xj3)>(abs(dddxj+xj3)/2))  || (dqjplus+h1*ddqjplus)*direction[j]<0.0#(dqjplus+h1*ddqjplus-qj1-e1*qj2)*direction[j]<0.0
        h2=cbrt(abs(6*quani/dddxi))
      h2=cbrt(abs(6*quani/dddxi))
      β=dxi+ddxi*h2/2+dddxi*h2*h2/6
      if (abs(dxi-xi1)>(abs(dxi+xi1)/2) || abs(ddxi-xi2)>(abs(ddxi+xi2)/2)  || abs(dddxi-xi3)>(abs(dddxi+xi3)/2))|| β*direction[index]<0.0

   # if (abs(dxi-xi1)>(abs(dxi+xi1)/2) || abs(ddxi-xi2)>(abs(ddxi+xi2)/2)  || abs(dddxi-xi3)>(abs(dddxi+xi3)/2))

        iscycle=true
        A=[aii aij;aji ajj]
        I=[1.0 0.0;0.0 1.0]
        U=[uij;uji]
        U2=[uij2;uji2]
        U3=[uij3;uji3]
        X=[xi;xjaux]


        h = ft-simt
        N=inv(I-h*A)
        R=h*I-(h*h/2)*A+(((h*h/2)*I-(h*h*h/6)*A)*N*A)
        L=inv(I-h*A+h*N*A-(h*h/2)*A*N*A)
        M=((h*h/2)*A-h*I)*N*(U2+h*U3)
        P=X+(h*U+(h*h/2)*U2+(h*h*h/6)*U3)
        S=-R*L*(M+U+h*U2+(h*h/2)*U3)-(((h*h/2)*I-(h*h*h/6)*A)*N*(U2+h*U3))+P
        Q=inv(I-h*A+R*L*A)*S
        
        qi=Q[1]
        qj=Q[2]
      
        if (abs(qi - xi) > quani || abs(qj - xjaux) > quanj) # removing this did nothing...check @btime later
          h1 = cbrt(abs(6*quani/dddxi));h2 = cbrt(abs(6*quanj/dddxj));   #later add derderX =1e-12 when x2==0
          h=min(h1,h2)
          N=inv(I-h*A)
          R=h*I-(h*h/2)*A+(((h*h/2)*I-(h*h*h/6)*A)*N*A)
        L=inv(I-h*A+h*N*A-(h*h/2)*A*N*A)
        M=((h*h/2)*A-h*I)*N*(U2+h*U3)
        P=X+(h*U+(h*h/2)*U2+(h*h*h/6)*U3)
        S=-R*L*(M+U+h*U2+(h*h/2)*U3)-(((h*h/2)*I-(h*h*h/6)*A)*N*(U2+h*U3))+P
        Q=inv(I-h*A+R*L*A)*S
        # Q=inv(I-h*A+h*N*A-h*h*A*N*A/2)*(((h*h/2)*A-h*I)*N*(U+h*U2)+X+h*U+h*h*U2/2)  
          qi=Q[1]
          qj=Q[2]
        end
  
        maxIter=600000
        while (abs(qi - xi) > quani || abs(qj - xjaux) > quanj) && (maxIter>0) && (h!=0.0)
          maxIter-=1
          h1 = h * (0.98*quani / abs(qi - xi));
          h2 = h * (0.98*quanj / abs(qj - xjaux));
          h=min(h1,h2)
        # h=h-0.00001
          N=inv(I-h*A)
          R=h*I-(h*h/2)*A+(((h*h/2)*I-(h*h*h/6)*A)*N*A)
          L=inv(I-h*A+h*N*A-(h*h/2)*A*N*A)
          M=((h*h/2)*A-h*I)*N*(U2+h*U3)
          P=X+(h*U+(h*h/2)*U2+(h*h*h/6)*U3)
          S=-R*L*(M+U+h*U2+(h*h/2)*U3)-(((h*h/2)*I-(h*h*h/6)*A)*N*(U2+h*U3))+P
          Q=inv(I-h*A+R*L*A)*S
          
          qi=Q[1]
          qj=Q[2]
          
        end

                                      
                                      
        if maxIter < 1
        println("maxtiter simult_val{3}")
        @show maxIter
        
      end

        q[index][0]=qi# store back helper vars
        q[j][0]=qj
      
      
        Q1=L*(M+A*Q+U+h*U2+(h*h/2)*U3)
        q[index][1]=Q1[1]# store back helper vars
        q[j][1]=Q1[2]

        Q2=N*(A*Q1+U2+h*U3)

        q[index][2]=Q2[1]/2# store back helper vars: /2 for taylor standard storage
        q[j][2]=Q2[2]/2

        tq[j]=simt
      end #end second dependecy check
  end # end outer dependency check
  #= if debug  
    println("end of iscycle function")
   end =#
  return iscycle
end


#######################################################################################################################################################
function updateOtherApprox(::Val{1},j::Int,index::Int,x::Vector{Taylor0{Float64}},q::Vector{Taylor0{Float64}},a::Vector{Vector{Float64}},u::MVector{T,MVector{T,MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}},tu::MVector{T,Float64},simt::Float64)where{T,O}
  diffQ=(q[index][0]-qaux[index][1])  
  if diffQ!=0
    a[j][index]=(x[j][1]-olddx[j][1])/diffQ
  else
    a[j][index]=0.0
  end
  u[k][j][1]=x[k][1]-a[k][k]*q[k][0]-a[k][j]*q[j][0]
  return nothing
end
function updateOtherApprox(::Val{2},k::Int,j::Int,x::Vector{Taylor0{Float64}},q::Vector{Taylor0{Float64}},a::Vector{Vector{Float64}},u::Vector{Vector{MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}},tu::MVector{T,Float64},simt::Float64)where{T,O}
  diffQ=q[j][0]-qaux[j][1]
  if diffQ != 0.0
      a[k][j]=(x[k][1]-olddx[k][1])/diffQ
  else
      a[k][j]=0.0
  end
 
   u[k][j][1]=x[k][1]-a[k][k]*q[k][0]-a[k][j]*q[j][0]
   u[k][j][2]=2*x[k][2]-a[k][k]*q[k][1]-a[k][j]*q[j][1]
  #  println("u inside updateOther after update= ",u[j][index])
    #tu[index]=simt  # comment did nothing but it makes sense to keep it because more accurate since u is changed
  return nothing
end

function updateOtherApprox(::Val{3},k::Int,j::Int,x::Vector{Taylor0{Float64}},q::Vector{Taylor0{Float64}},a::Vector{Vector{Float64}},u::Vector{Vector{MVector{O,Float64}}},qaux::MVector{T,MVector{O,Float64}},olddx::MVector{T,MVector{O,Float64}},tu::MVector{T,Float64},simt::Float64)where{T,O}
  diffQ=q[j][0]-qaux[j][1]
  # println("aji before updateoher= ",a[j][index])
  if diffQ != 0.0
      a[k][j]=(x[k][1]-olddx[k][1])/diffQ
  else
      a[k][j]=0.0
  end
 
     u[k][j][1]=x[k][1]-a[k][k]*q[k][0]-a[k][j]*q[j][0]
   u[k][j][2]=2*x[k][2]-a[k][k]*q[k][1]-a[k][j]*q[j][1]
   u[k][j][3]=6*x[k][3]-a[k][k]*2*q[k][2]-a[k][j]*2*q[j][2]
  #  println("u inside updateOther after update= ",u[j][index])
  #tu[k]=simt
    #tu[index]=simt  # comment did nothing but it makes sense to keep it because more accurate since u is changed
  return nothing
end
