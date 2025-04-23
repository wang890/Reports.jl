
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


@mtkmodel FixedTemperature begin
    @components begin
        port = HeatPort_b()
    end
    @parameters begin
        T, [description = "Fixed temperature boundary condition"]
    end
    @equations begin
        port.T ~ T
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