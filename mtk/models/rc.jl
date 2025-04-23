@mtkmodel RcHeating begin    
    @components begin
        resistor = HeatingResistor()           
        capacitor = Capacitor()
        source = ConstantVoltage()
        ground = Ground()
        fixedTemperature = FixedTemperature()        
    end      
    @equations begin        
        connect(source.p, resistor.p)
        connect(resistor.n, capacitor.p)
        connect(capacitor.n, source.n, ground.p) 
        connect(resistor.heat_port, fixedTemperature.port)       
    end
end