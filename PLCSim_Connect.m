function PLCSim_Connect(block)
%MSFUNTMPL_BASIC A Template for a Level-2 MATLAB S-Function
%   The MATLAB S-function is written as a MATLAB function with the
%   same name as the S-function. Replace 'msfuntmpl_basic' with the 
%   name of your S-function.
%
%   It should be noted that the MATLAB S-function is very similar
%   to Level-2 C-Mex S-functions. You should be able to get more
%   information for each of the block methods by referring to the
%   documentation for C-Mex S-functions.
%
%   Copyright 2003-2010 The MathWorks, Inc.

%%
%% The setup method is used to set up the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
NET.addAssembly ('C:\Users\slombard.KINGDOM\Documents\Visual Studio 2010\Projects\PLCSimConnector\PLCSimConnector\bin\Debug\PLCSimConnector.dll');
plcSim = PLCSimConnector.PLCSim;
NET.disableAutoRelease(plcSim);

setup(block);

%endfunction

%% Function: setup ===================================================
%% Abstract:
%%   Set up the basic characteristics of the S-function block such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%%
%%   Required         : Yes
%%   C-Mex counterpart: mdlInitializeSizes
%%
function setup(block)

% Register number of ports
block.NumInputPorts  = 0;
block.NumOutputPorts = 0;

set_param(block.BlockHandle, 'Priority', '0');

% Setup port properties to be inherited or dynamic
%block.SetPreCompInpPortInfoToDynamic;
%block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
%block.InputPort(1).Dimensions        = 1;
%block.InputPort(1).DatatypeID  = 0;  % double
%block.InputPort(1).Complexity  = 'Real';
%block.InputPort(1).DirectFeedthrough = true;

% Override output port properties
%block.OutputPort(1).Dimensions       = 1;
%block.OutputPort(1).DatatypeID  = 0; % double
%block.OutputPort(1).Complexity  = 'Real';
%block.OutputPort(1).SamplingMode = 'sample';

% Register parameters
block.NumDialogPrms     = 2;
block.DialogPrmsTunable = {'Nontunable','Nontunable'};

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [0 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';
Sim = PLCSimConnector.SimulatedPLC(plcSim);
set_param(block.BlockHandle, 'UserData', Sim);

%% -----------------------------------------------------------------
%% The MATLAB S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

block.RegBlockMethod('CheckParameters',         @CheckPrms);
block.RegBlockMethod('ProcessParameters',       @ProcessPrms);
block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Update', @Update);
block.RegBlockMethod('Terminate', @Terminate); % Required

%end setup
end

function CheckPrms(block)
  %projectName = block.DialogPrm(1).Data;
  %plcName = block.DialogPrm(2).Data;

  %if ~strcmp(projectName, '') && exist(projectName, 'file') == 0 
  %  error('PLCSim:Param', 'Project File %s does not exist', projectName)
  %end
  
  %if ~strcmp(plcName, '') && exist(plcName, 'file') == 0
  %  error('PLCSim:Param', 'PLC File %s does not exist', plcName)
  %end
end

%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C-Mex counterpart: mdlSetWorkWidths
%%
function DoPostPropSetup(block)
block.NumDworks = 1;
  
  block.Dwork(1).Name            = 'x1';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;
  
  Sim = get_param(block.BlockHandle, 'UserData');
  Sim.Project = PLCSimConnector.PCS7Project;
  Sim.Project.File = block.DialogPrm(1).Data;
    %% Register all tunable parameters as runtime parameters.
 % block.AutoRegRuntimePrms;
end

function ProcessPrms(block)

  %block.AutoUpdateRuntimePrms;
 
%endfunction
end

%%
%% InitializeConditions:
%%   Functionality    : Called at the start of simulation and if it is 
%%                      present in an enabled subsystem configured to reset 
%%                      states, it will be called when the enabled subsystem
%%                      restarts execution to reset the states.
%%   Required         : No
%%   C-MEX counterpart: mdlInitializeConditions
%%
function InitializeConditions(block)
block.Dwork(1).Data = 0;
%end InitializeConditions
end

%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this 
%%                      is the place to do it.
%%   Required         : No
%%   C-MEX counterpart: mdlStart
%%
function Start(block)
Sim = get_param(block.BlockHandle, 'UserData');
Sim.SimPLC.Connect();
block.Dwork(1).Data = 0;
%Sim = get_param(block.BlockHandle, 'UserData');

%end Start
end

%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlUpdate
%%
function Update(block)
Sim = get_param(block.BlockHandle, 'UserData');
Sim.UpdateImages();
%end Update
end

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)
Sim = get_param(block.BlockHandle, 'UserData');
Sim.SimPLC.Disconnect();
NET.enableAutoRelease(Sim.SimPLC);
%end Terminate
end
end
