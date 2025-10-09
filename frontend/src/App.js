import './App.css';
import axios from 'axios'
import React from 'react'

class App extends React.Component{
    state = { details: [], }

    componentDidMount() {
        let data;
        axios.get('http://localhost:8000')
            .then(res => {
                data = res.data;
                this.setState({
                    details: data
                });
            })
            .catch(err => {
                console.log(err);
            });
    }
    render() {
        return (
            <div>
                <header>Данные из Django</header>
                <hr />
                {this.state.details.map((output, id) => (
                    <div key={id}>
                        <h2>{output.title}</h2>
                        <p>{output.channel}</p>
                    </div>
                ))}
            </div>
        );
    }
}

export default App;
