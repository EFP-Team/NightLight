import { useBackend } from '../../backend';
import {
  Input,
  InfinitePlane,
  Stack,
  Box,
  Button,
} from '../../components';
import { Component } from 'inferno';
import { Window } from '../../layouts';
import { resolveAsset } from '../../assets';
import { CircuitInfo } from './CircuitInfo';
import { ABSOLUTE_Y_OFFSET, MOUSE_BUTTON_LEFT, TIME_UNTIL_PORT_RELEASE_WORKS } from './constants';
import { Connections } from './Connections';
import { ObjectComponent } from './ObjectComponent';
import { VariableMenu } from './VariableMenu';

export class IntegratedCircuit extends Component {
  constructor() {
    super();
    this.state = {
      locations: {},
      selectedPort: null,
      mouseX: null,
      mouseY: null,
      zoom: 1,
      backgroundX: 0,
      backgroundY: 0,
      menuOpen: false,
    };
    this.handlePortLocation = this.handlePortLocation.bind(this);
    this.handleMouseDown = this.handleMouseDown.bind(this);
    this.handleMouseUp = this.handleMouseUp.bind(this);
    this.handlePortClick = this.handlePortClick.bind(this);
    this.handlePortRightClick = this.handlePortRightClick.bind(this);
    this.handlePortUp = this.handlePortUp.bind(this);

    this.handlePortDrag = this.handlePortDrag.bind(this);
    this.handlePortRelease = this.handlePortRelease.bind(this);
    this.handleZoomChange = this.handleZoomChange.bind(this);
    this.handleBackgroundMoved = this.handleBackgroundMoved.bind(this);

    this.onVarClickedSetter = this.onVarClickedSetter.bind(this);
    this.onVarClickedGetter = this.onVarClickedGetter.bind(this);
    this.handleVarDropped = this.handleVarDropped.bind(this);
  }

  // Helper function to get an element's exact position
  getPosition(el) {
    let xPos = 0;
    let yPos = 0;

    while (el) {
      xPos += el.offsetLeft;
      yPos += el.offsetTop;
      el = el.offsetParent;
    }
    return {
      x: xPos,
      y: yPos + ABSOLUTE_Y_OFFSET,
    };
  }

  handlePortLocation(port, dom) {
    const { locations } = this.state;

    if (!dom) {
      return;
    }

    const lastPosition = locations[port.ref];
    const position = this.getPosition(dom);
    position.color = port.color;

    if (
      isNaN(position.x)
      || isNaN(position.y)
      || (lastPosition
        && lastPosition.x === position.x
        && lastPosition.y === position.y)
    ) {
      return;
    }
    locations[port.ref] = position;
    this.setState({ locations: locations });
  }

  handlePortClick(portIndex, componentId, port, isOutput, event) {
    if (this.state.selectedPort) {
      this.handlePortUp(portIndex, componentId, port, isOutput, event);
      return;
    }

    if (event.button !== MOUSE_BUTTON_LEFT) {
      return;
    }

    event.stopPropagation();
    this.setState({
      selectedPort: {
        index: portIndex,
        component_id: componentId,
        is_output: isOutput,
        ref: port.ref,
      },
    });

    this.handlePortDrag(event);

    this.timeUntilPortReleaseWorks
      = performance.now() + TIME_UNTIL_PORT_RELEASE_WORKS;

    window.addEventListener('mousemove', this.handlePortDrag);
    window.addEventListener('mouseup', this.handlePortRelease);
  }

  // mouse up called whilst over a port. This means we can check if selectedPort
  // exists and do perform some actions if it does.
  handlePortUp(portIndex, componentId, port, isOutput, event) {
    const { act, data: uiData } = useBackend(this.context);
    const {
      selectedPort,
    } = this.state;
    if (!selectedPort) {
      return;
    }
    if (selectedPort.is_output === isOutput) {
      return;
    }
    this.setState({
      selectedPort: null,
    });
    let data;
    if (isOutput) {
      data = {
        input_port_id: selectedPort.index,
        output_port_id: portIndex,
        input_component_id: selectedPort.component_id,
        output_component_id: componentId,
      };
    } else {
      data = {
        input_port_id: portIndex,
        output_port_id: selectedPort.index,
        input_component_id: componentId,
        output_component_id: selectedPort.component_id,
      };
    }
    act("add_connection", data);

    const { components } = uiData;
    const {
      input_component_id,
      input_port_id,
      output_component_id,
      output_port_id,
    } = data;

    const input_comp = components[input_component_id-1];
    const input_port = input_comp.input_ports[input_port_id-1];
    const output_comp = components[output_component_id-1];
    const output_port = output_comp.output_ports[output_port_id-1];
    // Do not predict ports that do not match because there is no guarantee
    // that they will properly match.
    // TODO: Implement proper prediction for this
    if (!input_port || input_port.type !== output_port.type) {
      return;
    }
    input_port.connected_to.push(isOutput? port.ref : selectedPort.ref);
  }

  handlePortDrag(event) {
    const { data } = useBackend(this.context);
    const { screen_x, screen_y } = data;
    this.setState((state) => ({
      mouseX: event.clientX - (state.backgroundX || screen_x),
      mouseY: event.clientY - (state.backgroundY || screen_y),
    }));
  }

  handlePortRelease(event) {
    window.removeEventListener('mouseup', this.handlePortRelease);

    if (this.timeUntilPortReleaseWorks > performance.now()) {
      return;
    }

    this.setState({
      selectedPort: null,
    });

    window.removeEventListener('mousemove', this.handlePortDrag);
  }

  handlePortRightClick(portIndex, componentId, port, isOutput, event) {
    const { act } = useBackend(this.context);

    event.preventDefault();
    act('remove_connection', {
      component_id: componentId,
      is_input: !isOutput,
      port_id: portIndex,
    });
  }

  handleZoomChange(newZoom) {
    this.setState({
      zoom: newZoom,
    });
  }

  handleBackgroundMoved(newX, newY) {
    this.setState({
      backgroundX: newX,
      backgroundY: newY,
    });
  }

  componentDidMount() {
    window.addEventListener('mousedown', this.handleMouseDown);
    window.addEventListener('mouseup', this.handleMouseUp);
  }

  componentWillUnmount() {
    window.removeEventListener('mousedown', this.handleMouseDown);
    window.removeEventListener('mouseup', this.handleMouseUp);
  }

  handleMouseDown(event) {
    const { act, data } = useBackend(this.context);
    const { examined_name } = data;
    if (examined_name) {
      act('remove_examined_component');
    }

    if (this.state.selectedPort) {
      this.handlePortRelease(event);
    }
  }

  handleMouseUp(event) {
    const { act } = useBackend(this.context);
    const { backgroundX, backgroundY } = this.state;
    if (backgroundX && backgroundY) {
      act("move_screen", {
        screen_x: backgroundX,
        screen_y: backgroundY,
      });
    }
  }

  onVarClickedSetter(event, variable) {
    this.handleVarClicked(event, variable, true);
  }

  onVarClickedGetter(event, variable) {
    this.handleVarClicked(event, variable, false);
  }

  handleVarClicked(event, variable, is_setter) {
    this.setState({
      draggingVariable: variable,
      variableIsSetter: is_setter,
    });

    window.addEventListener('mouseup', this.handleVarDropped);
  }

  handleVarDropped(event) {
    const { data, act } = useBackend(this.context);
    const {
      draggingVariable,
      variableIsSetter,
      backgroundX,
      backgroundY,
      zoom,
    } = this.state;
    const {
      screen_x,
      screen_y,
    } = data;

    const xPos = (event.clientX - (backgroundX || screen_x));
    const yPos = (event.clientY - (backgroundY || screen_y));

    act("add_setter_or_getter", {
      variable: draggingVariable,
      is_setter: variableIsSetter,
      rel_x: xPos*Math.pow(zoom, -1),
      rel_y: (yPos + ABSOLUTE_Y_OFFSET)*Math.pow(zoom, -1),
    });

    this.setState({
      draggingVariable: null,
      variableIsSetter: null,
    });

    window.removeEventListener('mouseup', this.handleVarDropped);
  }

  render() {
    const { act, data } = useBackend(this.context);
    const {
      components,
      display_name,
      examined_name,
      examined_desc,
      examined_notices,
      examined_rel_x,
      examined_rel_y,
      screen_x,
      screen_y,
      is_admin,
      variables,
      global_basic_types,
    } = data;
    const { locations, selectedPort, menuOpen } = this.state;
    const connections = [];

    for (const comp of components) {
      if (comp === null) {
        continue;
      }

      for (const input of comp.input_ports) {
        for (const output of input.connected_to) {
          const output_port = locations[output];
          connections.push({
            color: (output_port && output_port.color) || 'blue',
            from: output_port,
            to: locations[input.ref],
          });
        }
      }
    }

    if (selectedPort) {
      const { mouseX, mouseY, zoom } = this.state;
      const isOutput = selectedPort.is_output;
      const portLocation = locations[selectedPort.ref];
      const mouseCoords = {
        x: (mouseX)*Math.pow(zoom, -1),
        y: (mouseY + ABSOLUTE_Y_OFFSET)*Math.pow(zoom, -1),
      };
      connections.push({
        color: (portLocation && portLocation.color) || 'blue',
        from: isOutput? portLocation : mouseCoords,
        to: isOutput? mouseCoords : portLocation,
      });
    }

    return (
      <Window
        width={1200}
        height={800}
        buttons={(
          <Box
            width="160px"
            position="absolute"
            top="5px"
            height="22px"
          >
            <Stack>
              <Stack.Item grow>
                <Input
                  fluid
                  placeholder="Circuit Name"
                  value={display_name}
                  onChange={(e, value) => act("set_display_name", { display_name: value })}
                />
              </Stack.Item>
              <Stack.Item basis="24px">
                <Button
                  position="absolute"
                  top={0}
                  color="transparent"
                  icon="cog"
                  selected={menuOpen}
                  onClick={() => this.setState((state) => ({
                    menuOpen: !state.menuOpen,
                  }))}
                />
              </Stack.Item>
              {!!is_admin && (
                <Stack.Item>
                  <Button
                    position="absolute"
                    top={0}
                    color="transparent"
                    onClick={() => act("save_circuit")}
                    icon="save"
                  />
                </Stack.Item>
              )}
            </Stack>
          </Box>
        )}
      >
        <Window.Content
          style={{
            'background-image': 'none',
          }}>
          <InfinitePlane
            width="100%"
            height="100%"
            backgroundImage={resolveAsset('grid_background.png')}
            imageWidth={900}
            onZoomChange={this.handleZoomChange}
            onBackgroundMoved={this.handleBackgroundMoved}
            initialLeft={screen_x}
            initialTop={screen_y}
          >
            {components.map(
              (comp, index) =>
                comp && (
                  <ObjectComponent
                    key={index}
                    {...comp}
                    index={index + 1}
                    onPortUpdated={this.handlePortLocation}
                    onPortLoaded={this.handlePortLocation}
                    onPortMouseDown={this.handlePortClick}
                    onPortRightClick={this.handlePortRightClick}
                    onPortMouseUp={this.handlePortUp}
                  />
                )
            )}
            <Connections connections={connections} />
          </InfinitePlane>
          {!!examined_name && (
            <CircuitInfo
              position="absolute"
              className="CircuitInfo__Examined"
              top={`${examined_rel_y}px`}
              left={`${examined_rel_x}px`}
              name={examined_name}
              desc={examined_desc}
              notices={examined_notices}
            />
          )}
          {!!menuOpen && (
            <Box
              position="absolute"
              left={0}
              bottom={0}
              height="20%"
              minHeight="175px"
              minWidth="600px"
              width="50%"
              style={{
                "border-radius": "0px 32px 0px 0px",
                "background-color": "rgba(0, 0, 0, 0.3)",
                "-ms-user-select": "none",
              }}
              unselectable="on"
            >
              <VariableMenu
                variables={variables}
                types={global_basic_types}
                onClose={(event) => this.setState({ menuOpen: false })}
                onAddVariable={(name, type, event) => act("add_variable", {
                  variable_name: name,
                  variable_datatype: type,
                })}
                onRemoveVariable={(name, event) => act("remove_variable", {
                  variable_name: name,
                })}
                handleMouseDownSetter={this.onVarClickedSetter}
                handleMouseDownGetter={this.onVarClickedGetter}
                style={{
                  "border-radius": "0px 32px 0px 0px",
                }}
              />
            </Box>
          )}
        </Window.Content>
      </Window>
    );
  }
}

