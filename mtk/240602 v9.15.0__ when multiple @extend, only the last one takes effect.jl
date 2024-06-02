using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as d

@connector Pin begin
    v(t) # Potential at the pin
    i(t), [connect = Flow] # Current flowing into the pin
end

@mtkmodel OnePort begin
    @components begin
        p = Pin()
        n = Pin()
    end
    @variables begin
        v(t) # Voltage drop of the two pins (= p.v - n.v)
        i(t) # Current flowing into the pin
    end
    @equations begin
        v ~ p.v - n.v
        0 ~ p.i + n.i
        i ~ p.i
    end
end

@mtkmodel Ground begin
    @components begin
        p = Pin()
    end
    @equations begin
        p.v ~ 0
    end
end

@mtkmodel Capacitor begin
    @extend i,v = oneport = OnePort()
    @parameters begin
        C # Capacitance
    end
    @equations begin
        i ~ C * d(v)
    end
end

@mtkmodel ConstantVoltage begin
    @extend v, = oneport = OnePort()    
    @parameters begin
        V # Value of constant voltage
    end
    @equations begin
        v ~ V
    end
end


@connector HeatPort begin
    T(t)
    Q_flow(t), [connect = Flow]
end

@connector HeatPort_a begin
    @extend T, Q_flow = heatPort_a = HeatPort()
end

@connector HeatPort_b begin
    @extend T, Q_flow = heatPort_b = HeatPort()
end

"""this conditional HeatPort in order to describe
 the power loss via Resistor to a thermal network
 """
@mtkmodel ConditionalHeatPort begin
    @structural_parameters begin        
        useHeatPort = false  # = true, if heatPort is enabled
    end    
    @parameters begin              
        T = 293.15  # Default environment temperature under which the device is, if useHeatPort = false                  
    end
    @variables begin
        T_heatPort(t) # also means: environment temperature under which the device is
        LossPower(t) # Loss power leaving component via heatPort
    end
        
    @components begin
        heatPort = HeatPort_a()
    end      
       
    @equations begin
        if useHeatPort     
            T_heatPort ~ heatPort.T
            LossPower ~ -heatPort.Q_flow 
        else       
            T_heatPort ~ T                         
        end
    end
end


@mtkmodel Resistor begin   
    @structural_parameters begin        
        use_Heat_Port = false       
    end   

    @extend i,v,p,n = onePort = OnePort()

    # Switch between the two by keeping or  canceling the comment statement

    # @components begin        
    #     conditionalHeatPort = ConditionalHeatPort(; useHeatPort=use_Heat_Port)
    # end

    @extend T_heatPort, LossPower, heatPort = conditionalHeatPort = ConditionalHeatPort(; useHeatPort=use_Heat_Port)  
               
    @parameters begin
        R               # Resistance at temperature T_ref
        T_ref = 300.15  # Reference temperature, 27 celsius degree                          
        alpha = 0       # Temperature coefficient of resistance (R_actual = R*(1 + alpha*(T_heatPort - T_ref)) 
    end
    @variables begin
        R_actual(t)    # Actual resistance = R*(1 + alpha*(T_heatPort - T_ref))       
    end
    @equations begin
        # # when conditionalHeatPort as @components       
        # R_actual ~ R*(1 + alpha*(conditionalHeatPort.T_heatPort - T_ref)) 
        # v ~ R_actual * i
        # conditionalHeatPort.LossPower ~ v * i

        # when conditionalHeatPort as @extend
        R_actual ~ R*(1 + alpha*(T_heatPort - T_ref)) 
        v ~ R_actual * i
        LossPower ~ v * i
    end
end

@mtkmodel FixedTemperature begin
    @components begin
        port = HeatPort_b()
    end
    @parameters begin
        T # Fixed temperature at port
    end
    @equations begin
        port.T ~ T
    end
end


@mtkmodel Rc begin
    @structural_parameters begin        
        resistorUseHeatPort = false
    end
    @components begin                
        resistor = Resistor(; R=1.0, use_Heat_Port=resistorUseHeatPort)        
        capacitor = Capacitor(C=1.0)
        source = ConstantVoltage(V=1.0)
        ground = Ground()
        if resistorUseHeatPort
            fixedTemperature = FixedTemperature(T=400.15)
        end
    end
    @equations begin
        connect(source.p, resistor.p)
        connect(resistor.n, capacitor.p)
        connect(capacitor.n, source.n, ground.p)        
        # # when conditionalHeatPort as @components
        # if resistorUseHeatPort
        #     connect(resistor.conditionalHeatPort.heatPort, fixedTemperature.port)
        # end
        
        # when conditionalHeatPort as @extend
        if resistorUseHeatPort
            connect(resistor.heatPort, fixedTemperature.port)
        end
    end
end

breakpoint = 1  # just for breakpoint when debug

@mtkbuild sys = Rc(; resistorUseHeatPort=true)
"""
Unknowns (2)
    capacitor₊v(t) [defaults to Unassigned]
    resistor₊i(t) [defaults to Unassigned]
Parameters (7)
    fixedTemperature₊T [defaults to 400.15]
    resistor₊R [defaults to 1.0]
    resistor₊T_ref [defaults to 300.15]
    resistor₊alpha [defaults to 0]
    resistor₊conditionalHeatPort₊T [defaults to 293.15]
    capacitor₊C [defaults to 1.0]
    source₊V [defaults to 1.0]
"""
breakpoint = 2  # just for breakpoint when debug

u0s = [sys.capacitor.v=>0.0, sys.resistor.i=>0.0]
paras = [sys.resistor.alpha=>0.01]
tspan = (0, 20.0)
saveat = 0.1

using OrdinaryDiffEq

prob = ODEProblem(sys, u0s, tspan, paras)
sol = solve(prob, Rosenbrock23(), saveat=saveat)

breakpoint = 3 # just for breakpoint when debug

using Plots  
p = plot(sol,vars=(1))
display(p)

breakpoint = 4 # just for breakpoint when debug
