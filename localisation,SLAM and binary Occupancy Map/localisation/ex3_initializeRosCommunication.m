rosshutdown;
pause(1)
rosshutdown
setenv('ROS_IP','192.168.88.1') % VMnet1 here from ipconfig
rosinit('localhost') % from Virtual machine desktop


%% rossubscribers and rospublishers, scanner

% subscribe
gazeboSub = rossubscriber('/gazebo/model_states');
odom_callback = rossubscriber('/odom', @odomCallback);
odom_callback2 = rossubscriber('/odom', @odomVelocityCallback);


% define global variables and test subscribers
pause(2);
actualPose = updateActualPose(gazeboSub);
actualPose(:);
% global feedbackPose
% feedbackPose(:);
global odomPose
odomPose(:);
global odomTwist
odomTwist(:);
global cameraMsg
cameraImage = readImage(cameraMsg);
global cameraMsg2
depthImage = readImage(cameraMsg2);

% publish
[pub, msg] = rospublisher('/mobile_base/commands/velocity', ...
                          'geometry_msgs/Twist');

% other
scanner = MoroLandmarkScanner();

%% callback functions

function odomCallback(~, msg)
% ODOMCALLBACK Subscriber callback function for pose data    
%   ODOMCALLBACK(~,MSG) returns no arguments - it instead sets a 
%   global variable to the values of position and orientation that are
%   received in the ROS message MSG.

    % declare global variable to store position and orientation
    global odomPose
    msgPose = msg.Pose.Pose;
    odomPose = xyTheta(msgPose);
end

function odomVelocityCallback(~, msg)

    % declare global variable to store linear and angular velocity
    global odomTwist
    msgTwist = msg.Twist.Twist;
    twist2D = vxvyOmega(msgTwist);
    odomTwist = [twist2D(1)
                 twist2D(3)];
end


%% other functions

function pose2D = xyTheta(msgPose)
    % extract position and orientation from the ROS message and assign the
    % data to the returned variable.
    euler = quat2eul([msgPose.Orientation.W, ...
                      msgPose.Orientation.X, ...
                      msgPose.Orientation.Y, ...
                      msgPose.Orientation.Z]);
    pose2D = [msgPose.Position.X
              msgPose.Position.Y
              euler(1)];
end

function twist2D = vxvyOmega(msgTwist)
    % extract velocities from the ROS message and assign the
    % data to the global variable.
    twist2D = [msgTwist.Linear.X
               msgTwist.Linear.Y
               msgTwist.Angular.Z];
end
