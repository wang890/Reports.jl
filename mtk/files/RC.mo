within ;
model RcHeating
  Modelica.Electrical.Analog.Basic.Resistor resistor(
    R=1,
    T_ref=300.15,
    alpha=0.01,
    useHeatPort=true)
    annotation (Placement(transformation(extent={{-30,46},{-10,66}})));
  Modelica.Electrical.Analog.Basic.Capacitor capacitor(v(start=0.0), C=1)
    annotation (Placement(transformation(extent={{0,46},{20,66}})));
  Modelica.Electrical.Analog.Basic.Ground ground
    annotation (Placement(transformation(extent={{-82,-4},{-62,16}})));
  Modelica.Electrical.Analog.Sources.ConstantVoltage constantVoltage(V=1)
    annotation (Placement(transformation(extent={{-80,-28},{-62,-12}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature(T=400.15)
    annotation (Placement(transformation(extent={{-46,-6},{-26,14}})));
equation
  connect(constantVoltage.p, resistor.p) annotation (Line(points={{-80,-20},{
          -88,-20},{-88,56},{-30,56}},
                                  color={0,0,255}));
  connect(resistor.n, capacitor.p) annotation (Line(points={{-10,56},{0,56}},
                         color={0,0,255}));
  connect(capacitor.n, constantVoltage.n)
    annotation (Line(points={{20,56},{24,56},{24,-20},{-62,-20}},
                                                          color={0,0,255}));
  connect(constantVoltage.n, ground.p)
    annotation (Line(points={{-62,-20},{-56,-20},{-56,16},{-72,16}},
                                                   color={0,0,255}));
  connect(fixedTemperature.port, resistor.heatPort)
    annotation (Line(points={{-26,4},{-20,4},{-20,46}}, color={191,0,0}));
  annotation (uses(Modelica(version="4.0.0")));
end RcHeating;
