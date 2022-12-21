defmodule Memex.Ai.SentenceTransformers do
  alias Bumblebee.Shared

  def embed(text) when is_binary(text) do
    embedding =
      Nx.Serving.batched_run(__MODULE__, [text])
      |> Nx.to_flat_list()
  end

  """
  {:ok, _} =
    Supervisor.start_link(
      [
        PhoenixDemo.Endpoint,
        {Nx.Serving, serving: Memex.Ai.SentenceTransformers.serving(), name: Memex.Ai.SentenceTransformers, batch_timeout: 100}
      ],
      strategy: :one_for_one
    )
  """

  def serving() do
    model_name = "sentence-transformers/all-MiniLM-L6-v2"
    {:ok, model_info} = Bumblebee.load_model({:hf, model_name})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, model_name})

    Memex.Ai.SentenceTransformers.sentence_embeddings(model_info, tokenizer,
      compile: [batch_size: 10, sequence_length: 128],
      defn_options: [compiler: EXLA]
    )
  end

  def test(query \\ "TicketSwap") do
    embedding = Nx.Serving.batched_run(__MODULE__, [query])

    embeddings =
      Nx.Serving.batched_run(__MODULE__, [
        "pgvector/pgvector: Open-source vector similarity search for Postgres MacBook Pro: https://github.com/pgvector/pgvector",
        "Install Jupyter Notebook | Learn How to Install and Use Jupyter Notebook",
        "A picture of London at night",
        "Fastai on Apple M1 - Deep Learning - fast.ai Course Forums: https://forums.fast.ai/t/fastai-on-apple-m1/86059/50"
      ])

    Bumblebee.Utils.Nx.cosine_similarity(embedding, embeddings)
  end

  def sentence_embeddings(model_info, tokenizer, opts \\ []) do
    %{model: model, params: params, spec: spec} = model_info
    Shared.validate_architecture!(spec, :base)
    opts = Keyword.validate!(opts, [:compile, defn_options: []])

    compile = opts[:compile]
    defn_options = opts[:defn_options]

    batch_size = compile[:batch_size]
    sequence_length = compile[:sequence_length]

    if compile != nil and (batch_size == nil or sequence_length == nil) do
      raise ArgumentError,
            "expected :compile to be a keyword list specifying :batch_size and :sequence_length, got: #{inspect(compile)}"
    end

    {_init_fun, predict_fun} = Axon.build(model)

    scores_fun = fn params, input ->
      outputs = predict_fun.(params, input)
      outputs.pooled_state
    end

    Nx.Serving.new(
      fn ->
        scores_fun =
          Shared.compile_or_jit(scores_fun, defn_options, compile != nil, fn ->
            inputs = %{
              "input_ids" => Nx.template({batch_size, sequence_length}, :s64),
              "token_type_ids" => Nx.template({batch_size, sequence_length}, :s64),
              "attention_mask" => Nx.template({batch_size, sequence_length}, :s64)
            }

            [params, inputs]
          end)

        fn inputs ->
          inputs = Shared.maybe_pad(inputs, batch_size)
          scores_fun.(params, inputs)
        end
      end,
      batch_size: batch_size
    )
    |> Nx.Serving.client_preprocessing(fn input ->
      {texts, multi?} = Shared.validate_serving_input!(input, &is_binary/1, "a string")

      inputs = Bumblebee.apply_tokenizer(tokenizer, texts)

      {Nx.Batch.concatenate([inputs]), multi?}
    end)
    |> Nx.Serving.client_postprocessing(fn scores, metadata, multi? ->
      scores |> IO.inspect(label: "103")
      multi? |> IO.inspect(label: "98")
      metadata |> IO.inspect(label: "99")
      # Mean Pooling - Take attention mask into account for correct averaging
      # def mean_pooling(model_output, attention_mask):
      #   token_embeddings = model_output[0] #First element of model_output contains all token embeddings
      #   input_mask_expanded = attention_mask.unsqueeze(-1).expand(token_embeddings.size()).float()
      #   return torch.sum(token_embeddings * input_mask_expanded, 1) / torch.clamp(input_mask_expanded.sum(1), min=1e-9)

      token_embeddings = scores[0]
      input_mask_expanded = Nx.unsqueece(token_embeddings, -1)
      Nx.size(token_embeddings)

      scores
      |> Shared.normalize_output(multi?)
    end)
  end
end
